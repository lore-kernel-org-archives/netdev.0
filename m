From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Mon, 05 Feb 2007 17:32:58 -0800 (PST)
Message-ID: <20070205.173258.102576664.davem@davemloft.net>
References: <20070203150301.GA32659@hmsreliant.homelinux.net>
	<20070205205651.GB484@hmsreliant.homelinux.net>
	<20070206.102405.86919923.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55555
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965449AbXBFBc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 20:32:59 -0500
In-Reply-To: <20070206.102405.86919923.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 06 Feb 2007 10:24:05 +0900 (JST)

> > @@ -498,7 +500,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
> >          msg->icmph.icmp6_unused = 0;
> >          msg->icmph.icmp6_router    = router;
> >          msg->icmph.icmp6_solicited = solicited;
> > -        msg->icmph.icmp6_override  = override;
> > +	msg->icmph.icmp6_override  = override;
> > +
> >  
> >          /* Set the target address. */
> >  	ipv6_addr_copy(&msg->target, solicited_addr);
> 
> Why do you "change" this?

He edited it, but then reverted his change but in the
process added proper tab characters :-)  It is easy
to miss things like this.

This whole file has a lot of lines lacking proper tab
characters.
