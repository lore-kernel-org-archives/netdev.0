From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 5 Jan 2008 15:48:05 -0600
Message-ID: <20080105154805.118eb3d1@vader.jdub.homelinux.org>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
	<1199528388.7291.55.camel@pasglop>
	<200801051338.17957.sr@denx.de>
	<1199566386.7291.58.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:65097 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756878AbYAEVsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 16:48:11 -0500
Received: by py-out-1112.google.com with SMTP id u52so11784651pyb.10
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2008 13:48:11 -0800 (PST)
In-Reply-To: <1199566386.7291.58.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 06 Jan 2008 07:53:06 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Sat, 2008-01-05 at 13:38 +0100, Stefan Roese wrote:
> > On Saturday 05 January 2008, Benjamin Herrenschmidt wrote:
> > > On Sat, 2008-01-05 at 10:50 +0100, Stefan Roese wrote:
> > > > Performance tests done by AMCC have shown that 256 buffer increase the
> > > > performance of the Linux EMAC driver. So let's update the default
> > > > values to match this setup.
> > > >
> > > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > > ---
> > >
> > > Do we have the numbers ? Did they also measure latency ?
> > 
> > I hoped this question would not come. ;) No, unfortunately I don't have any 
> > numbers. Just the recommendation from AMCC to always use 256 buffers.
> 
> Ok. Well, it's just a .config option so I suppose the patch is fine. Can
> you also update the defconfigs (at least for the recent AMCC boards) ?

No need for a defconfig update patch.  Paul or I usually do a general
defconfig update for most boards before the next kernel version.  This
will get picked up then.

josh
