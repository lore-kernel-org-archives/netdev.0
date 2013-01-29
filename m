From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: do not create neighbor entries for local delivery
Date: Tue, 29 Jan 2013 11:53:36 +0100
Message-ID: <20130129105336.GA7571@minipsycho.orion>
References: <50F6ABCA.4020804@redhat.com>
 <20130116.162813.1734293658687337225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mleitner@redhat.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:35809 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433Ab3A2Kxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 05:53:41 -0500
Received: by mail-we0-f176.google.com with SMTP id s43so201919wey.35
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 02:53:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130116.162813.1734293658687337225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 16, 2013 at 10:28:13PM CET, davem@davemloft.net wrote:
>From: Marcelo Ricardo Leitner <mleitner@redhat.com>
>Date: Wed, 16 Jan 2013 11:31:54 -0200
>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index
>> 7c34c01b515b7ac370f8021ba6f5ec4c654e9e41..b63e33bcbdfbc1bd78af0b98ffc2d211805214ea
>> 100644
>
>Patch corrupted by your email client.
>
>Note also that YOSHIFUJI Hideaki's patches to remove the cached neighbour
>entirely from ipv6 routes will have the same effect, so your patch won't
>be needed.

Dave, wouldn't this patch be suitable candidate for -net (/-stable) ?

I can repost this properly.

Thanks, Jiri



>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
