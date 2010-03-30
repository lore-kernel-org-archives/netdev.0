From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH 09/17] pcmcia: update gfp/slab.h includes
Date: Tue, 30 Mar 2010 08:36:09 +0200
Message-ID: <20100330063609.GA4498@comet.dominikbrodowski.net>
References: <1269885165-18617-1-git-send-email-tj@kernel.org>
 <1269885165-18617-10-git-send-email-tj@kernel.org>
 <20100329193203.GA8450@comet.dominikbrodowski.net>
 <20100330103129.b76a70e3.sfr@canb.auug.org.au>
 <4BB14D7B.4010602@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>, Dmitry Torokhov <dtor@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:36020 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752271Ab0C3GvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 02:51:23 -0400
Content-Disposition: inline
In-Reply-To: <4BB14D7B.4010602@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 10:01:47AM +0900, Tejun Heo wrote:
> Hello,
> 
> On 03/30/2010 08:31 AM, Stephen Rothwell wrote:
> > Hi Dominik,
> > On Mon, 29 Mar 2010 21:32:03 +0200 Dominik Brodowski <linux@dominikbrodowski.net> wrote:
> >>
> >> On Tue, Mar 30, 2010 at 02:52:37AM +0900, Tejun Heo wrote:
> >>> Implicit slab.h inclusion via percpu.h is about to go away.  Make sure
> >>> gfp.h or slab.h is included as necessary.
> >>>
> >>> Signed-off-by: Tejun Heo <tj@kernel.org>
> >>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> >>> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> >> Acked-by: Dominik Brodowski <linux@dominikbrodowski.net>
> > 
> > The plan here is for you to put this in your tree now.  It is safe to do
> > so and Tejun can't carry it because this does not apply to mainline. 

Okay, applied it.

> Stephen's patches on drivers/input/misc/ad714x.c and pcf8574_keypad.c
> into input tree.

That's nothing I can do anything about -- Dmitry?

Best,
	Dominik
