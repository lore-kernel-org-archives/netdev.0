From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] udp: Need to make ip6_udp_tunnel.c have GPL license
Date: Mon, 22 Sep 2014 13:17:04 -0700
Message-ID: <CA+mtBx8EbRBxS2OF65cWjBHGMXhLkbmMjibOtRRBMTqWGmgD5g@mail.gmail.com>
References: <1411411184-11993-1-git-send-email-therbert@google.com>
	<20140922.150832.1458585102153232594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:59136 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbaIVURF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:17:05 -0400
Received: by mail-ig0-f180.google.com with SMTP id a13so3419531igq.13
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 13:17:04 -0700 (PDT)
In-Reply-To: <20140922.150832.1458585102153232594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy, even with the is patch I still can't get VXLAN to work again. I
am assuming this is a problem related to the common UDP tunnel
functions. I haven't had time to look into it in depth, can you verify
if there is an issue.

Thanks,
Tom


On Mon, Sep 22, 2014 at 12:08 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 22 Sep 2014 11:39:44 -0700
>
>> Unable to load various tunneling modules without this:
>>
>> [   80.679049] fou: Unknown symbol udp_sock_create6 (err 0)
>> [   91.439939] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
>> [   91.439954] ip6_udp_tunnel: Unknown symbol __put_net (err 0)
>> [   91.457792] vxlan: Unknown symbol udp_sock_create6 (err 0)
>> [   91.457831] vxlan: Unknown symbol udp_tunnel6_xmit_skb (err 0)
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> Applied, thanks Tom.
