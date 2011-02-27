From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sun, 27 Feb 2011 15:22:08 -0800 (PST)
Message-ID: <20110227.152208.102543719.davem@davemloft.net>
References: <4D690D16.8020503@gmail.com>
	<27369.1298749377@death>
	<20110227125816.GB2814@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, nicolas.2p.debian@gmail.com, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	anna.fischer@hp.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751852Ab1B0XVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 18:21:32 -0500
In-Reply-To: <20110227125816.GB2814@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sun, 27 Feb 2011 13:58:17 +0100

> That is very true. And given that af_packet uses orig_dev to obtain
> ifindex, it can be replaced by skb->skb_iif. That way we can get rid of
> orig_dev parameter for good.

I would rather see a complete patch set submitting at a unit, thanks.

I've already marked your V3 last night as "changes requested" in
patchwork for this reason.
