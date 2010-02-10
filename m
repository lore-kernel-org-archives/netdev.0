From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 19:24:11 +0000
Message-ID: <20100210192411.GH27173@sirena.org.uk>
References: <7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local> <fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com> <4B72FAB2.5000804@freescale.com> <20100210.113720.1026572228166328165.imp@bsdimp.com> <fa686aa41002101112o66a74f60jc65fdffb48fd7213@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "M. Warner Losh" <imp@bsdimp.com>, scottwood@freescale.com,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	afleming@freescale.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:51001 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab0BJTYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:24:14 -0500
Content-Disposition: inline
In-Reply-To: <fa686aa41002101112o66a74f60jc65fdffb48fd7213@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 12:12:14PM -0700, Grant Likely wrote:
> On Wed, Feb 10, 2010 at 11:37 AM, M. Warner Losh <imp@bsdimp.com> wrote:

> > There are times that you'd want a list of PHY addresses to use. ?This
> > suggests a bitmask, but I don't know if they are common enough to
> > warrant the extra burden on the usual case...

> Are you talking a single MAC attached to multiple PHYs?  If so, then
> the current device tree binding doesn't support this, but it would be
> easy to extend the current binding by making the phy-handle property a
> list of phy nodes phandes.

There's also the entertaining case I've dealt with (pre device tree but
actually on PowerPC) where the MAC has multiple PHYs attached but they
should only be exposed to userspace and the driver should rely on MII
configuration provided by userspace without touching them.
