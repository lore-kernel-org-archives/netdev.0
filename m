From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH 09/17] pcmcia: update gfp/slab.h includes
Date: Mon, 29 Mar 2010 23:56:05 -0700
Message-ID: <20100330065605.GA12764__42653.0148987242$1269932202$gmane$org@core.coreip.homeip.net>
References: <1269885165-18617-1-git-send-email-tj@kernel.org>
 <1269885165-18617-10-git-send-email-tj@kernel.org>
 <20100329193203.GA8450@comet.dominikbrodowski.net>
 <20100330103129.b76a70e3.sfr@canb.auug.org.au>
 <4BB14D7B.4010602@kernel.org>
 <20100330063609.GA4498@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Dominik Brodowski <linux@dominikbrodowski.net>,
	Tejun Heo <tj@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@v
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.211.172]:54941 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764Ab0C3G4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 02:56:11 -0400
Content-Disposition: inline
In-Reply-To: <20100330063609.GA4498@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 08:36:09AM +0200, Dominik Brodowski wrote:
> On Tue, Mar 30, 2010 at 10:01:47AM +0900, Tejun Heo wrote:
> > Hello,
> > 
> > On 03/30/2010 08:31 AM, Stephen Rothwell wrote:
> > > Hi Dominik,
> > > On Mon, 29 Mar 2010 21:32:03 +0200 Dominik Brodowski <linux@dominikbrodowski.net> wrote:
> > >>
> > >> On Tue, Mar 30, 2010 at 02:52:37AM +0900, Tejun Heo wrote:
> > >>> Implicit slab.h inclusion via percpu.h is about to go away.  Make sure
> > >>> gfp.h or slab.h is included as necessary.
> > >>>
> > >>> Signed-off-by: Tejun Heo <tj@kernel.org>
> > >>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> > >>> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> > >> Acked-by: Dominik Brodowski <linux@dominikbrodowski.net>
> > > 
> > > The plan here is for you to put this in your tree now.  It is safe to do
> > > so and Tejun can't carry it because this does not apply to mainline. 
> 
> Okay, applied it.
> 
> > Stephen's patches on drivers/input/misc/ad714x.c and pcf8574_keypad.c
> > into input tree.
> 
> That's nothing I can do anything about -- Dmitry?
> 

Yes, I will roll teh relevant parts into respective patches if you don't
mind.

-- 
Dmitry
