From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
	matching table
Date: Thu, 31 Jan 2008 10:14:58 +1100
Message-ID: <1201734898.8146.0.camel@pasglop>
References: <1200476230-14026-1-git-send-email-sr@denx.de>
	 <1200477239.6755.21.camel@pasglop>
	 <20080116090110.1b7b2f00@zod.rchland.ibm.com>
	 <200801300716.52463.sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35448 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595AbYA3XUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 18:20:32 -0500
In-Reply-To: <200801300716.52463.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-01-30 at 07:16 +0100, Stefan Roese wrote:
> On Wednesday 16 January 2008, Josh Boyer wrote:
> > On Wed, 16 Jan 2008 20:53:59 +1100
> >
> > Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > > On Wed, 2008-01-16 at 10:37 +0100, Stefan Roese wrote:
> > > > With the removal the the "rgmii-interface" device_type property from
> > > > the dts files, the newemac driver needs an update to only rely on
> > > > compatible property.
> > > >
> > > > Signed-off-by: Stefan Roese <sr@denx.de>
> > >
> > > I need to test if it works on CAB, can't change the DT on those. I'll
> > > let you know tomorrow.
> >
> > This should be fine on CAB.  The rgmii node has:
> >
> > compatible = "ibm,rgmii-axon", "ibm,rgmii"
> >
> > so the match should still catch on the latter.
> 
> How about this patch? Ben, if you think this is ok then we should make sure 
> that it goes in in this merge-window, since the other dts patch relies on it.

It's fine.

Ben.


