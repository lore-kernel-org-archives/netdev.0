From: Nate Case <ncase@xes-inc.com>
Subject: Re: [PATCH] PHYLIB: Add BCM5482 PHY support
Date: Wed, 30 Jan 2008 17:45:50 -0600
Message-ID: <1201736751.12444.176.camel@localhost.localdomain>
References: <1201623540.12444.121.camel@localhost.localdomain>
	 <Pine.LNX.4.64N.0801300936040.20317@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:41631 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492AbYA3XqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 18:46:06 -0500
In-Reply-To: <Pine.LNX.4.64N.0801300936040.20317@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-01-30 at 09:51 +0000, Maciej W. Rozycki wrote:
> > +static struct phy_driver bcm5482_driver = {
> > +    .phy_id		= 0x0143bcb0,
> > +	.phy_id_mask	= 0xfffffff0,
> 
>  Please check formatting above and also I am a bit curious as to why the 
> ID is so different from the other ones -- the number is meant to be based 
> on the OUI assigned to the manufacturer.  Otherwise your addition is fine.

I'll re-submit with the formatting fixed.

I can't figure out why the ID is so different from the others, but I did
double-check it and test it on real hardware.

For what it's worth, I've found a lot of inconsistency in these ID
values. For example, the chips with ID1 == 0x0020 seem to use the wrong
set of OUI bits (22:7 instead of 21:6), while others (BCM5221) with ID1
== 0x0040 do it properly conforming to the IEEE standard.

I can't figure out how they got the ID values for the BCM5482.  If you
extract the OUI from 0x0143bcb0, you get 0x0050ef (which the *BSD guys
list as an alternate "mangled" Broadcom OUI).  The BCM5787 and BCM5755
also seem to share this same ID formula with the BCM5482.

- Nate Case <ncase@xes-inc.com>

