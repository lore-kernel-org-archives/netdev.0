From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: btusb suspend/resume bug...
Date: Mon, 22 Sep 2008 23:42:46 +0200
Message-ID: <200809222342.46735.rjw@sisk.pl>
References: <20080916.155123.181085856.davem@davemloft.net> <1221668269.6782.8.camel@californication> <1222064651.13064.6.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:35701 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753189AbYIVVg7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 17:36:59 -0400
In-Reply-To: <1222064651.13064.6.camel@californication>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 22 of September 2008, Marcel Holtmann wrote:
> Hi Dave,
> 
> > > Marcel, others, please bring some kind of closure to this
> > > regression list entry:
> > > 
> > > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11442
> > > Subject		: btusb hibernation/suspend breakage in current -git
> > > Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
> > > Date		: 2008-08-25 11:37 (19 days old)
> > > References	: http://marc.info/?l=linux-bluetooth&m=121966402012074&w=4
> > > Handled-By	: Oliver Neukum <oliver@neukum.org>
> > > Patch		: http://marc.info/?l=linux-bluetooth&m=121967226027323&w=4
> > > 
> > > There is a patch, it is tested, so the only course of action at
> > > this point is to merge the fix or declare that this really isn't
> > > a regression.
> > > 
> > > My impression is the later, because the driver btusb is replacing
> > > doesn't handle suspend/resume either.  Isn't that right?
> > 
> > the original patch that I had was expecting changes in the USB subsystem
> > that I deemed to much at this point. However Oliver got a patch that
> > would make it work without the USB changes. I am still testing it.
> > 
> > Let me see if I get some free minutes during the PlumbersConf to get
> > this fully tested.
> 
> so I took the patch apart and actually found a few more issues. I am not
> sure if they should be applied this late in -rc phase.
> 
> Rafael, can you pull from my tree and test the changes:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git
> 
> It would be interesting if these fixes are enough.

They appear to be enough.  I haven't had any suspend/resume failures with them
applied.

Thanks,
Rafael
