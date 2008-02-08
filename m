From: David Dillow <dave@thedillows.org>
Subject: Re: [patch 1/7] typhoon section fix
Date: Fri, 08 Feb 2008 13:21:57 -0500
Message-ID: <1202494917.5298.3.camel@lap75545.ornl.gov>
References: <200802081120.m18BK6cL021623@imap1.linux-foundation.org>
	 <1202479150.4349.0.camel@obelisk.thedillows.org>
	 <20080208095233.722d7c47.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	sam@ravnborg.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lap75545.ornl.gov ([160.91.210.54]:34225 "EHLO
	lap75545.ornl.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758687AbYBHSez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 13:34:55 -0500
In-Reply-To: <20080208095233.722d7c47.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-02-08 at 09:52 -0800, Andrew Morton wrote:
> On Fri, 08 Feb 2008 08:59:10 -0500 David Dillow <dave@thedillows.org> wrote:
> > On Fri, 2008-02-08 at 03:11 -0800, akpm@linux-foundation.org wrote:
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > 
> > > gcc-3.4.4 on powerpc:
> > > 
> > > drivers/net/typhoon.c:137: error: version causes a section type conflict
> > > 
> > > Cc: Jeff Garzik <jeff@garzik.org>
> > > Cc: Sam Ravnborg <sam@ravnborg.org>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > > -static const char version[] __devinitdata =
> > > +static char version[] __devinitdata =
> > >      "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
> > 
> > Wouldn't going to __devinitconst be better? I'll try to whip up a patch
> > and test-compile it.
> 
> Sam told me that doesn't work right, that this approach is the one to use
> and, iirc, that __devinitcont and friends will be removed.
> 
> I'm not sure why, actually.  I think I missed that dicussion.

Thanks for the searchable terms -- this is the thread, I think:
http://lkml.org/lkml/2008/2/3/99

It looks like Jan had an idea to fold the const into the __devinitconst
marker, and if that seems to be viable, then I'd prefer that route to
keep the const'ness where it is possible.

Otherwise, your patch is fine as-is.

Acked-by: David Dillow <dave@thedillows.org>
