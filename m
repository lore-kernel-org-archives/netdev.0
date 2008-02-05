From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
 matching table
Date: Tue, 5 Feb 2008 15:12:16 -0600
Message-ID: <20080205151216.4ff3c32a@weaponx>
References: <1200476230-14026-1-git-send-email-sr@denx.de>
	<1200477239.6755.21.camel@pasglop>
	<20080116090110.1b7b2f00@zod.rchland.ibm.com>
	<200801300716.52463.sr@denx.de>
	<1201734898.8146.0.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, Stefan Roese <sr@denx.de>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44121 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760995AbYBEVMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 16:12:20 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m15LCJ4r015116
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 16:12:19 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m15LCJ4k127942
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 14:12:19 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m15LCI5v030413
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 14:12:19 -0700
In-Reply-To: <1201734898.8146.0.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jan 2008 10:14:58 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Wed, 2008-01-30 at 07:16 +0100, Stefan Roese wrote:
> > On Wednesday 16 January 2008, Josh Boyer wrote:
> > > On Wed, 16 Jan 2008 20:53:59 +1100
> > >
> > > Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > > > On Wed, 2008-01-16 at 10:37 +0100, Stefan Roese wrote:
> > > > > With the removal the the "rgmii-interface" device_type property from
> > > > > the dts files, the newemac driver needs an update to only rely on
> > > > > compatible property.
> > > > >
> > > > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > >
> > > > I need to test if it works on CAB, can't change the DT on those. I'll
> > > > let you know tomorrow.
> > >
> > > This should be fine on CAB.  The rgmii node has:
> > >
> > > compatible = "ibm,rgmii-axon", "ibm,rgmii"
> > >
> > > so the match should still catch on the latter.
> > 
> > How about this patch? Ben, if you think this is ok then we should make sure 
> > that it goes in in this merge-window, since the other dts patch relies on it.
> 
> It's fine.

Jeff, any chance this can get into .25 soon?  I have another patch
queued up behind this one that requires it, and I don't see it in any
of your trees or branches.

Or, if you aren't opposed, I can take it through Paul's tree with your
Ack.

josh
