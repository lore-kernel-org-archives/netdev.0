From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Wed, 11 Jan 2017 23:27:58 +0100
Message-ID: <20170111222758.GG13033@lunn.ch>
References: <587410EF.5090607@ti.com>
 <20170109225641.GB22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545A3@DFLE11.ent.ti.com>
 <20170109235534.GH22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545C9@DFLE11.ent.ti.com>
 <20170110015336.GA7160@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57702 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933227AbdAKW2e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 17:28:34 -0500
Content-Disposition: inline
In-Reply-To: <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 10:18:02PM +0000, Kwok, WingMan wrote:
> 
> 
> > -----Original Message-----
> > From: Andrew Lunn [mailto:andrew@lunn.ch]
> > Sent: Monday, January 09, 2017 8:54 PM
> > To: Kwok, WingMan
> > Cc: Karicheri, Muralidharan; netdev@vger.kernel.org
> > Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
> > 
> > > From Marvell's brief description
> > http://www.marvell.com/transceivers/alaska-gbe/,
> > > it seems that 88E1510/1518 don't support fiber. Only 88E1512 does.
> > In
> > > that case, the fiber support patch is not applicable to
> > 88E1510/1518.
> > 
> > O.K. That makes it easier.
> > 
> > Please add the relevant IDs to include/linux/marvell.h, and add
> > entries to driver/net/phy/marvell.c for 1512 with SUPPORTED_FIBRE and
> > 1510 and 1518 without.
> > 
> >      Andrew
> 
> By any chance you have the ID of 1512?

Nope, sorry.

Try Russell King.

    Andrew
