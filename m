From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 15:43:30 -0700 (PDT)
Message-ID: <20071005.154330.95907448.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<200710051846.19965.netdev@axxeo.de>
	<4706B83D.40306@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, netdev@vger.kernel.org, Ariel.Hendel@Sun.COM,
	Greg.Onufer@Sun.COM, jeff@garzik.org, Ashley.Saulsbury@Sun.COM
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59419
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761867AbXJEWng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 18:43:36 -0400
In-Reply-To: <4706B83D.40306@sun.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Fri, 05 Oct 2007 15:18:37 -0700

> > 
> >> +static void niu_set_max_burst(struct niu *np, struct tx_ring_info *rp)
> >> +{
> >> +	int mtu = np->dev->mtu;
> >> +
> >> +	rp->max_burst = mtu + 32;
> >> +	if (rp->max_burst > 4096)
> >> +		rp->max_burst = 4096;
> > 
> > Why 32 and 4096? (Magic values)
> 
> These values were recommended by the HW designers for fair utilization 
> of DRR feature among TX/RX rings.

I'll add macro defines for these, thanks for the feedback.
