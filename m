From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Tue, 06 Feb 2007 10:44:08 +0900 (JST)
Message-ID: <20070206.104408.87339760.yoshfuji@linux-ipv6.org>
References: <20070205205651.GB484@hmsreliant.homelinux.net>
	<20070206.102405.86919923.yoshfuji@linux-ipv6.org>
	<20070205.173258.102576664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53647 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933167AbXBFBmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 20:42:46 -0500
In-Reply-To: <20070205.173258.102576664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070205.173258.102576664.davem@davemloft.net> (at Mon, 05 Feb 2007 17:32:58 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Tue, 06 Feb 2007 10:24:05 +0900 (JST)
> 
> > > @@ -498,7 +500,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
> > >          msg->icmph.icmp6_unused = 0;
> > >          msg->icmph.icmp6_router    = router;
> > >          msg->icmph.icmp6_solicited = solicited;
> > > -        msg->icmph.icmp6_override  = override;
> > > +	msg->icmph.icmp6_override  = override;
> > > +
> > >  
> > >          /* Set the target address. */
> > >  	ipv6_addr_copy(&msg->target, solicited_addr);
> > 
> > Why do you "change" this?
> 
> He edited it, but then reverted his change but in the
> process added proper tab characters :-)  It is easy
> to miss things like this.

I know, you know. :-)

> This whole file has a lot of lines lacking proper tab
> characters.

Yes, I agree, but I think it is different issue, and
maybe, we should check and change other places as well,
in separate patch(es).

--yoshfuji
