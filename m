From: Rene Rebe <rene@exactcode.com>
Subject: Re: [PATCH] r8152: The Microsoft Surface docks also use R8152.
Date: Tue, 28 Mar 2017 08:00:39 +0200 (CEST)
Message-ID: <20170328.080039.1883015502420058477.rene@exactcode.com>
References: <1490893565.24247.9.camel@redhat.com>
        <D17D7867-DC1B-40FE-BA88-0B200EA86CF3@exactcode.com>
        <1490897562.24247.15.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org, nic_swsd@realtek.com
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.exactcode.de ([144.76.154.42]:50336 "EHLO mx.exactcode.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934100AbdC3VAy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 17:00:54 -0400
In-Reply-To: <1490897562.24247.15.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, 2017-03-30 at 19:47 +0200, René Rebe wrote:
> > Hi,
> > 
> > On Mar 30, 2017, at 19:06, Dan Williams <dcbw@redhat.com> wrote:
> > 
> > > On Tue, 2017-03-28 at 06:42 +0200, Rene Rebe wrote:
> > > > Without this the generic cdc_ether grabs the device,
> > > > and does not really work.
> > > 
> > > Does this need a corresponding blacklist in cdc_ether
> > > then?  Otherwise
> > > you're really depending on driver loading order.
> > 
> > right, I already test build, and will send after reboot.
> > 
> > Any other nitpick in the meantime?
> 
> Nope, other than it's pretty odd that the device would expose standard
> cdc-ether compatible USB descriptors, but apparently not be compatible
> with cdc-ether?  Are we sure we don't just need a tweak or something to
> cdc-ether?

Based on the existing glue and blacklist code I would assume most if
not all R8152 devices have this "issue".

However, sometimes the standard macOS driver works with it. IIRC if
the dock is connected after booting or so, so maybe the BIOS network
boot glue alters the behavior or whatever. It never was able to TX any
packet with the generic Linux cdc-ether, though.

Anyways, given the existing specific Linux driver I would assume it is
better to use it in any case.

       René

-- 
  René Rebe, ExactCODE GmbH, Lietzenburger Str. 42, DE-10789 Berlin
  http://exactcode.com | http://t2-project.org | http://rene.rebe.de
