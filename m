From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4] net: ethernet: faraday: To support device tree usage.
Date: Wed, 01 Feb 2017 16:47:20 +0100
Message-ID: <5763539.ftMn9eb5Wh@wuerfel>
References: <20170124084606.GA11764@app09> <CAK8P3a2Zr6=4x8JRa313DQ2ND0V=8eL0yKkrd93wbdxkiOtmSw@mail.gmail.com> <20170127221733.tcoudehkp5b5jnfw@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: green.hu@gmail.com, David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, devicetree@vger.kernel.org,
        andrew@lunn.ch, jiri@resnulli.us,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        f.fainelli@gmail.com, Mark Rutland <mark.rutland@arm.com>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:51346 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdBAPrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 10:47:46 -0500
In-Reply-To: <20170127221733.tcoudehkp5b5jnfw@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 27, 2017 4:17:33 PM CET Rob Herring wrote:
> On Wed, Jan 25, 2017 at 10:09:20PM +0100, Arnd Bergmann wrote:
> > On Wed, Jan 25, 2017 at 6:34 PM, David Miller <davem@davemloft.net> wrote:
> > > From: Greentime Hu <green.hu@gmail.com>
> > > Date: Tue, 24 Jan 2017 16:46:14 +0800
> > >> We also use the same binding document to describe the same faraday ethernet
> > >> controller and add faraday to vendor-prefixes.txt.
> > >
> > > Why are you renaming the MOXA binding file instead of adding a completely new one
> > > for faraday?  The MOXA one should stick around, I don't see a justification for
> > > removing it.
> > 
> > This was my suggestion, basically fixing the name of the existing
> > binding, which was
> > accidentally named after one of the users rather than the company that did the
> > hardware.
> > 
> > We can't change the compatible string, but I'd much prefer having only
> > one binding
> > file for this device rather than two separate ones that could possibly become
> > incompatible in case we add new properties to them. If there is only
> > one of them,
> > naming it according to the hardware design is the general policy.
> > 
> > Note that we currently have two separate device drivers, but that is more a
> > historic artifact, and if we ever get around to merging them into one driver,
> > that should not impact the binding.
> 
> The change is fine with me, but the subject and commit message need some 
> work. I'm guessing faraday licensed this to MOXA or something?

Correct, Faraday just produces IP blocks.

> Why is the new name preferred or better?

The situation is similar to the designware "dwmac", which for historic
reasons is called "stmmac" in Linux, both for the binding and the driver
name. I think this should have been dwmac from the start, but changing
it earlier is much easier than changing it later.

	Arnd
