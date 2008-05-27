From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Mon, 26 May 2008 23:20:58 -0700
Message-ID: <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>
References: <20080411135714.GA8137@tp64> <483B9EBE.5030703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:64565 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbYE0GU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 02:20:58 -0400
Received: by rv-out-0506.google.com with SMTP id l9so2772477rvb.1
        for <netdev@vger.kernel.org>; Mon, 26 May 2008 23:20:58 -0700 (PDT)
In-Reply-To: <483B9EBE.5030703@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/26 Patrick McHardy <kaber@trash.net>:
> Joonwoo Park wrote:
>>
>> To be polite to the PACKET,
>> Don't kill the unclassified & hardware accelerated vlan packets if netdev
>> is in promiscuous, set packet type with PACKET_OTHERHOST. Put the vlan tag
>> into skb->cb for all hardware accelerated vlan packets.
>
> Conceptually I think this patch goes in the right direction,
> one question remaining is when to invalidate the VLAN tag again.
>
> The only solution I could come up with is invalidating it in
> netif_receive_skb() when the receiving device is not a VLAN
> device and additionally invalidating it in all callers of
> dev_queue_xmit except VLAN itself, but I would really prefer
> something less error prone without touching netif_receive_skb().
>
> BTW, I already have a patch queued to move the VLAN tag from
> skb->cb to a seperate skb member to fix the the conflict with
> qdiscs (this should also allow to use vlan accel through virtual
> network devices later on). So please don't resend, I'll integrate
> the patch on top of this change once we find a good spot for
> invalidation.
>

Thanks Patrick for reviewing.
I'll be looking forward to seeing it on the list.

Thanks,
Joonwoo
