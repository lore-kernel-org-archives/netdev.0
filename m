From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/sunhme.c patch
Date: Mon, 29 Oct 2007 15:10:25 -0700 (PDT)
Message-ID: <20071029.151025.87460351.davem@davemloft.net>
References: <4725F416.2030100@wonderland.us.com>
	<Pine.LNX.4.64.0710291606260.26070@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toms@wonderland.us.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49940
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753146AbXJ2WKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 18:10:23 -0400
In-Reply-To: <Pine.LNX.4.64.0710291606260.26070@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Mon, 29 Oct 2007 16:11:18 +0100 (CET)

> 
> On Oct 29 2007 08:54, Tom Southerland wrote:
> >
> > This patch provides a unique mac address for all interfaces
> > for the Sun QFE card (non-sparc).  It takes the base mac from
> > the first interface and increments the mac address for the
> > other interfaces.
> 
> Where is the difference to a SPARC QFE? PCI is PCI after all, is not it?

This is exactly why I wish this patch had been posted to
netdev@vger.kernel.org, now we have a dialogue going and even if I add
netdev to the CC: now, you can't follow it completely as a netdev
subscriber without going to the lkml archives.

To answer the question, yes it is just a normal PCI device, they put 4
HME chips behind a PCI bridge.  However, the OpenFirmware on the cards
usually creates device node properties for these PCI devices for the
local ethernet addresses.  That's what he's trying to duplicate here.
