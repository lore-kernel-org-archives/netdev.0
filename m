From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] tun: add the RFS support
Date: Mon, 13 Jan 2014 08:49:31 -0800
Message-ID: <CA+mtBx9hpzKctKQBHDQUiG_ekSrXyEP4ALKf1h4Ox0fL4g04TQ@mail.gmail.com>
References: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
	<20131231.133200.1111966466957616549.davem@davemloft.net>
	<CA+mtBx8b_D+JQaphS4LCbAVKRWE5Tz1-P_eVxJJdG-FbMdWPdw@mail.gmail.com>
	<CAEH94LjdMyZ_SVf5YvzqEhPzYanFQUwLsm+e8Hp_Y5XU4_hkeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:60832 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbaAMQtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 11:49:32 -0500
Received: by mail-ie0-f173.google.com with SMTP id u16so5855741iet.18
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 08:49:32 -0800 (PST)
In-Reply-To: <CAEH94LjdMyZ_SVf5YvzqEhPzYanFQUwLsm+e8Hp_Y5XU4_hkeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 5:29 AM, Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
> On Wed, Jan 1, 2014 at 6:33 AM, Tom Herbert <therbert@google.com> wrote:
>> Zhi,
> HI, Tom
>>
>> Thanks for following up on these patches. It would still be nice to
>> have performance numbers to show the impact. These will be helpful for
>> the next task of integrating RFS into virtio-net.
> I don't get why RFS need to be integrated into virtio-net since
> virtio-net has supported mq. Can you give some clue? thanks.
>
In this case RFS would be the mechanism for selecting the RX queue. We
can either use the tun approach which is to match the RX queue to the
TX queue for a flow, or expose it as accelerated RFS to the guest.
Fine grained control of the queue selection should have value.

>>
>> Tom
>>
>> On Tue, Dec 31, 2013 at 10:32 AM, David Miller <davem@davemloft.net> wrote:
>>> From: Zhi Yong Wu <zwu.kernel@gmail.com>
>>> Date: Sun, 22 Dec 2013 18:54:30 +0800
>>>
>>>> Since Tom Herbert's hash related patchset was modified and got merged,
>>>> his pachset about adding support for RFS on tun flows also need to get
>>>> adjusted accordingly. I tried to update them, and before i will start
>>>> to do some perf tests, i hope to get one correct code base, so it's time
>>>> to post them out now. Any constructive comments are welcome, thanks.
>>>
>>> Series applied to net-next, thanks.
>
>
>
> --
> Regards,
>
> Zhi Yong Wu
