From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: Add BCM5482 PHY support
Date: Wed, 30 Jan 2008 09:51:23 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0801300936040.20317@blysk.ds.pg.gda.pl>
References: <1201623540.12444.121.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:35653 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333AbYA3Jvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 04:51:36 -0500
In-Reply-To: <1201623540.12444.121.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jan 2008, Nate Case wrote:

> +static struct phy_driver bcm5482_driver = {
> +    .phy_id		= 0x0143bcb0,
> +	.phy_id_mask	= 0xfffffff0,

 Please check formatting above and also I am a bit curious as to why the 
ID is so different from the other ones -- the number is meant to be based 
on the OUI assigned to the manufacturer.  Otherwise your addition is fine.

  Maciej
