From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
	matching table
Date: Wed, 6 Feb 2008 10:35:54 -0600
Message-ID: <20080206163554.GA18575@lixom.net>
References: <1202300519-7294-1-git-send-email-sr@denx.de> <20080206160157.GA18228@lixom.net> <20080206102340.1cdf7f8d@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Roese <sr@denx.de>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:39722 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369AbYBFQeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 11:34:44 -0500
Content-Disposition: inline
In-Reply-To: <20080206102340.1cdf7f8d@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 10:23:40AM -0600, Josh Boyer wrote:
> On Wed, 6 Feb 2008 10:01:57 -0600
> Olof Johansson <olof@lixom.net> wrote:
> 
> > On Wed, Feb 06, 2008 at 01:21:59PM +0100, Stefan Roese wrote:
> > > With the removal the the "rgmii-interface" device_type property from the
> > > dts files, the newemac driver needs an update to only rely on compatible
> > > property.
> > 
> > What about systems using an older dts, such as one kexec:ing from an
> > older kernel?
> 
> Like what?  Kexec doesn't work on 4xx yet.

Sure, but similar restrictions would apply for customers who have a
flashed device tree that want to boot a newer kernel. Deprecating old
device tree support is something that should be done very carefully.

> > Just because the device tree source is distributed in the kernel tree
> > doesn't mean it can give up backwards compatibility.
> 
> We checked Axon, which is the only non-DTS machine that uses EMAC and
> it will work fine with this change.

Ah, ok. I remember discussions about this patch before then, sounds like
it's safe. I just triggered on the dts-centric patch description.

Objections withdrawn. :)


-Olof
