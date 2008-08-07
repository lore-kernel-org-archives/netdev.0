From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates
Date: Thu, 07 Aug 2008 02:19:01 -0700 (PDT)
Message-ID: <20080807.021901.172722402.davem@davemloft.net>
References: <20080807085009.GA31681@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56011
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754031AbYHGMZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:25:04 -0400
In-Reply-To: <20080807085009.GA31681@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 7 Aug 2008 04:50:09 -0400

> Rough summary:
> 
> * fixes
> 
> * additions of the variety where only a few lines are added, to support
>   new hardware (forcedeth, netxen)
> 
> * a WAN update that got missed, and IMO should go in for 2.6.27.  This
>   is addressing the complaint about too much stuff still using syncppp,
>   so things get switched more to generic HDLC.  MUCH more typesafe, and
>   links directly with struct net_device, rather than through opaque void
>   pointers and syncppp-specific structs.
> 
> * bonding update with core bits previously ack'd by you
> 
> * that ethtool.h change increasing speed to 32 bits
> 
> Please pull from 'upstream-davem' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

I've pulled, but the WAN bits were borderline.  If you couldn't pull
that WAN stuff in on time, that's just the way it goes sometimes.
