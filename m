From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 18:02:34 +0000
Message-ID: <20090312180234.GF14491@shareable.org>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam> <F884D8C3-E35B-4239-8D72-165EE528FCAC@prograde.net> <20090312.070554.96115441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mboards@prograde.net, shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:50301 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbZCLSCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 14:02:52 -0400
Content-Disposition: inline
In-Reply-To: <20090312.070554.96115441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> > I'm confused by this. If I'm NFS-booting the board then how do I get
> > to those userland tools if I don't have a valid MAC address in place
> > to do the root mount?
> 
> Initial ramdisk.

Aren't you basically implying that the in-kernel DHCP client and NFS
mounting should be removed from the kernel too?

I'd agree with that; it's the trend.  But it seems pretty harsh to say
"you can do DHCP+NFS now, but if you want to set the MAC address too,
then you have to reimplement DHCP+NFS a completely different way from
scratch first".

-- Jamie
