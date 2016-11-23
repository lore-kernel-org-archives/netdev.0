From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: forward unknown mc packets on
 mv88e6097
Date: Wed, 23 Nov 2016 18:32:30 +0100
Message-ID: <20161123173230.GD8760@lunn.ch>
References: <20161123165022.GD12698@gruene.netmodule.intranet>
 <20161123165440.4894-1-stefan.eichenberger@netmodule.com>
 <20161123165949.GB8760@lunn.ch>
 <20161123171441.GE12698@gruene.netmodule.intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Eichenberger <eichest@gmail.com>,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50088 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938550AbcKWRcd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 12:32:33 -0500
Content-Disposition: inline
In-Reply-To: <20161123171441.GE12698@gruene.netmodule.intranet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 06:14:41PM +0100, Stefan Eichenberger wrote:
> On Wed, Nov 23, 2016 at 05:59:49PM +0100, Andrew Lunn wrote:
> > On Wed, Nov 23, 2016 at 05:54:40PM +0100, Stefan Eichenberger wrote:
> > > Packets with unknown destination addresses are not forwarded to the cpu
> > > port on mv88e6097 based switches (e.g. MV88E6097) at the moment. This
> > > commit enables PORT_CONTROL_FORWARD_UNKNOWN_MC for this family.
> > 
> > Please try adding MV88E6XXX_FLAG_EDSA to
> > MV88E6XXX_FLAGS_FAMILY_6097. That is the better fix if it works.
> 
> I was even wondering what EDSA means:) Thanks this solved the problem!

Great.

We should fix up a few minor issues and resubmit.

What is the status of the first patch, which added 6097 to the driver?
I don't think David accepted it yet. So lets make one patchset
containing the two patches.

The subject line of the patches need to have net-next in it. e.g.

[PATCH net-next 0/2] Add support for the MV88e6097

Include a cover node, saying what the patchset as a whole does.
This gets used as the merge commit message.

Then the two patches.

When posting the patchset, please start a new thread. A new version of
a patchset or patch should be a new thread.

Thanks
	Andrew
