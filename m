From: Andy Zhou <azhou@nicira.com>
Subject: Re: [PATCH net-next] udp: Need to make ip6_udp_tunnel.c have GPL license
Date: Tue, 23 Sep 2014 12:00:35 -0700
Message-ID: <CACzMAJJvkG0WJoaUOeW6vrFMhzp0T9o6+259rMknwt7Rv9R-sw@mail.gmail.com>
References: <1411411184-11993-1-git-send-email-therbert@google.com>
	<20140922.150832.1458585102153232594.davem@davemloft.net>
	<CA+mtBx8EbRBxS2OF65cWjBHGMXhLkbmMjibOtRRBMTqWGmgD5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:48270 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753973AbaIWTAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 15:00:51 -0400
Received: by mail-oa0-f54.google.com with SMTP id m19so5420158oag.13
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 12:00:37 -0700 (PDT)
In-Reply-To: <CA+mtBx8EbRBxS2OF65cWjBHGMXhLkbmMjibOtRRBMTqWGmgD5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, it is a bug in the Vxlan transmit code. I have sent out a patch
a while ago.  Would you please give it try?

https://patchwork.ozlabs.org/patch/392275/

Thanks for letting me know and the help to reproduce the bug off list.

Andy

On Mon, Sep 22, 2014 at 1:17 PM, Tom Herbert <therbert@google.com> wrote:
> Andy, even with the is patch I still can't get VXLAN to work again. I
> am assuming this is a problem related to the common UDP tunnel
> functions. I haven't had time to look into it in depth, can you verify
> if there is an issue.
>
> Thanks,
> Tom
>
>
> On Mon, Sep 22, 2014 at 12:08 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Mon, 22 Sep 2014 11:39:44 -0700
>>
>>> Unable to load various tunneling modules without this:
>>>
>>> [   80.679049] fou: Unknown symbol udp_sock_create6 (err 0)
>>> [   91.439939] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
>>> [   91.439954] ip6_udp_tunnel: Unknown symbol __put_net (err 0)
>>> [   91.457792] vxlan: Unknown symbol udp_sock_create6 (err 0)
>>> [   91.457831] vxlan: Unknown symbol udp_tunnel6_xmit_skb (err 0)
>>>
>>> Signed-off-by: Tom Herbert <therbert@google.com>
>>
>> Applied, thanks Tom.
