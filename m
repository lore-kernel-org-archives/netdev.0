From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: forward unknown mc packets on
 mv88e6097
Date: Wed, 23 Nov 2016 19:01:25 +0100
Message-ID: <20161123180125.GF8760@lunn.ch>
References: <20161123165022.GD12698@gruene.netmodule.intranet>
 <20161123165440.4894-1-stefan.eichenberger@netmodule.com>
 <20161123165949.GB8760@lunn.ch>
 <20161123171441.GE12698@gruene.netmodule.intranet>
 <20161123174040.GE8760@lunn.ch>
 <877f7uxevf.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Eichenberger <eichest@gmail.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50151 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753022AbcKWSBu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 13:01:50 -0500
Content-Disposition: inline
In-Reply-To: <877f7uxevf.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 12:52:52PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > And if you have a recent version of tcpdump, it will decode
> > the header.
> 
> Since d729eb4, thanks to you Andrew ;-)
> 
> I move up the cleanup of ports setup in my priority list.

Hi Vivien

Please take a look at my mv88e6390 branch. I already refactored this
code, because the mv88e6390 does something slightly different...

I hope to post another batch of mv88e6390 patches soon, and they will
include this cleanup. Since they will clash with these patches, i will
post them first as RFC.

      Andrew
