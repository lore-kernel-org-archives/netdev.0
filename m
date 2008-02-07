From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
	matching table
Date: Thu, 07 Feb 2008 13:47:28 +1100
Message-ID: <1202352448.7079.112.camel@pasglop>
References: <1202300519-7294-1-git-send-email-sr@denx.de>
	 <20080206160157.GA18228@lixom.net>
	 <20080206102340.1cdf7f8d@zod.rchland.ibm.com>
	 <20080206163554.GA18575@lixom.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@gmail.com>, Stefan Roese <sr@denx.de>,
	linuxppc-dev@ozlabs.org, jeff@garzik.org, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45261 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758830AbYBGCsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 21:48:12 -0500
In-Reply-To: <20080206163554.GA18575@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-02-06 at 10:35 -0600, Olof Johansson wrote:
> On Wed, Feb 06, 2008 at 10:23:40AM -0600, Josh Boyer wrote:
> > On Wed, 6 Feb 2008 10:01:57 -0600
> > Olof Johansson <olof@lixom.net> wrote:
> > 
> > > On Wed, Feb 06, 2008 at 01:21:59PM +0100, Stefan Roese wrote:
> > > > With the removal the the "rgmii-interface" device_type property from the
> > > > dts files, the newemac driver needs an update to only rely on compatible
> > > > property.
> > > 
> > > What about systems using an older dts, such as one kexec:ing from an
> > > older kernel?
> > 
> > Like what?  Kexec doesn't work on 4xx yet.
> 
> Sure, but similar restrictions would apply for customers who have a
> flashed device tree that want to boot a newer kernel. Deprecating old
> device tree support is something that should be done very carefully.

In that case, we -know- there was no such thing as the proper support
for 4xx in powerpc isn't really there before 2.6.25 anyway. The only
other is Cell/Axon which we verified still works.

Ben.


