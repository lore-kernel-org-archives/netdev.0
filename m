From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH v2 3/8] Documentation: bindings: net: add the Marvell
 PXA168 Ethernet controller
Date: Tue, 9 Sep 2014 18:52:26 +0100
Message-ID: <20140909175226.GE3896@leverpostej>
References: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com>
 <3827594.chb831jyvc@wuerfel>
 <20140909160136.GA26051@kwain>
 <2897714.QyEFFDa5hL@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org"
	<thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org" <zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org"
	<alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org" <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	"sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2897714.QyEFFDa5hL@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 09, 2014 at 06:47:35PM +0100, Arnd Bergmann wrote:
> On Tuesday 09 September 2014 18:01:36 Antoine Tenart wrote:
> > 
> > On Tue, Sep 09, 2014 at 05:58:12PM +0200, Arnd Bergmann wrote:
> > > On Tuesday 09 September 2014 16:44:03 Antoine Tenart wrote:
> > > > +- clocks: pointer to the clock for the device.
> > > > +- clock-names: should be "MFUCLK".
> > > 
> > > Clock names are normally not capitalized. Are you able to change
> > > that name when providing a binding or make it an anoymous clock?
> > > What does MFU stand for anyway?
> > 
> > Sure. I could have make it an anonymous clock but the name "MFUCLK" was
> > already used by the pxa168 Ethernet driver so I didn't wanted to change
> > that.
> 
> I believe you can just ask for an anonymous clock anyway and get the
> first one even if it has a name, but I didn't check.
> 
> In any case, we should not just take a clock name in a DT binding
> because it happened to be used by platform code. It's easy fix the
> platform code when someone makes a mistake there, but very hard to
> fix DT strings once there are users relying on a particular convention.

At least with names it's easy to add/remove abitrary sets of clocks. We
can be stuck with bad names but I don't think that's as big a concern.

So if there is an actual name for the clock input line (from the pov of
the consumer), I'd recommend using it. Note that this does not have to
be the current "MFUCLK" as used by platform data.

Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
