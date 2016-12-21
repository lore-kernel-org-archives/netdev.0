From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v5] net: dummy: Introduce dummy virtual functions
Date: Wed, 21 Dec 2016 21:06:12 +0100
Message-ID: <20161221200612.GM13857@orbyte.nwl.cc>
References: <20161220222621.32493-1-phil@nwl.cc>
 <20161221.133200.173665554896949124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40942 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756677AbcLUURK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Dec 2016 15:17:10 -0500
Content-Disposition: inline
In-Reply-To: <20161221.133200.173665554896949124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 01:32:00PM -0500, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Tue, 20 Dec 2016 23:26:21 +0100
> 
> > The idea for this was born when testing VF support in iproute2 which was
> > impeded by hardware requirements. In fact, not every VF-capable hardware
> > driver implements all netdev ops, so testing the interface is still hard
> > to do even with a well-sorted hardware shelf.
> > 
> > To overcome this and allow for testing the user-kernel interface, this
> > patch allows to turn dummy into a PF with a configurable amount of VFs.
> > 
> > Due to the assumption that all PFs are PCI devices, this implementation
> > is not completely straightforward: In order to allow for
> > rtnl_fill_ifinfo() to see the dummy VFs, a fake PCI parent device is
> > attached to the dummy netdev. This has to happen at the right spot so
> > register_netdevice() does not get confused. This patch abuses
> > ndo_fix_features callback for that. In ndo_uninit callback, the fake
> > parent is removed again for the same purpose.
> > 
> > Joint work with Sabrina Dubroca.
> > 
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> Please resubmit when net-next opens back up, thanks.

Sure, thanks for the heads-up!

Cheers, Phil
