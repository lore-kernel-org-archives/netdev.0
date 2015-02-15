From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: Reflect RX hash for transmit
Date: Sun, 15 Feb 2015 21:27:17 +0100
Message-ID: <54E10125.7060807@iogearbox.net>
References: <1424025438-1659-1-git-send-email-therbert@google.com>	<54E0FAA1.7000900@iogearbox.net> <CA+mtBx-Mp5k4TmoDK29ui=jB79drq-K-vhPqK3GgFNoqA2Mifg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49818 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106AbbBOU13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 15:27:29 -0500
In-Reply-To: <CA+mtBx-Mp5k4TmoDK29ui=jB79drq-K-vhPqK3GgFNoqA2Mifg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2015 09:19 PM, Tom Herbert wrote:
> On Sun, Feb 15, 2015 at 11:59 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 02/15/2015 07:37 PM, Tom Herbert wrote:
>>>
>>> This patch allows a driver to request that the receive hash it provides
>>> to the stack is reflected back in skb->hash for packets transmitted
>>> on the associated connection.
>>
>> [...]
>>>
>>> +       if (unlikely(skb->reflect_hash && sk->sk_txhash != skb->hash))
>>> +               sk->sk_txhash = skb->hash;
>>
>>
>> Is there also an initial user setting this somewhere?
>
> inet_set_txhash and ip6_set_txhash are called for connected sockets.
> There is no user API to set these.

Yes sure, this was maybe a bit unclear; I was referring to reflect_hash.

Thanks,
Daniel
