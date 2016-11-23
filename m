From: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: forward unknown mc packets on
 mv88e6097
Date: Wed, 23 Nov 2016 18:14:41 +0100
Message-ID: <20161123171441.GE12698@gruene.netmodule.intranet>
References: <20161123165022.GD12698@gruene.netmodule.intranet>
 <20161123165440.4894-1-stefan.eichenberger@netmodule.com>
 <20161123165949.GB8760@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stefan Eichenberger <eichest@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.netmodule.com ([194.29.26.242]:28544 "EHLO
        webmail.netmodule.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933977AbcKWRPG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:15:06 -0500
Content-Disposition: inline
In-Reply-To: <20161123165949.GB8760@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 05:59:49PM +0100, Andrew Lunn wrote:
> On Wed, Nov 23, 2016 at 05:54:40PM +0100, Stefan Eichenberger wrote:
> > Packets with unknown destination addresses are not forwarded to the cpu
> > port on mv88e6097 based switches (e.g. MV88E6097) at the moment. This
> > commit enables PORT_CONTROL_FORWARD_UNKNOWN_MC for this family.
> 
> Please try adding MV88E6XXX_FLAG_EDSA to
> MV88E6XXX_FLAGS_FAMILY_6097. That is the better fix if it works.

I was even wondering what EDSA means:) Thanks this solved the problem!

Regards
Stefan
