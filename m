From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/7] typhoon section fix
Date: Fri, 8 Feb 2008 09:52:33 -0800
Message-ID: <20080208095233.722d7c47.akpm@linux-foundation.org>
References: <200802081120.m18BK6cL021623@imap1.linux-foundation.org>
	<1202479150.4349.0.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	sam@ravnborg.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50283 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757989AbYBHRxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 12:53:38 -0500
In-Reply-To: <1202479150.4349.0.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Feb 2008 08:59:10 -0500 David Dillow <dave@thedillows.org> wrote:

> 
> On Fri, 2008-02-08 at 03:11 -0800, akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > gcc-3.4.4 on powerpc:
> > 
> > drivers/net/typhoon.c:137: error: version causes a section type conflict
> > 
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Cc: Sam Ravnborg <sam@ravnborg.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> > -static const char version[] __devinitdata =
> > +static char version[] __devinitdata =
> >      "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
> 
> Wouldn't going to __devinitconst be better? I'll try to whip up a patch
> and test-compile it.

Sam told me that doesn't work right, that this approach is the one to use
and, iirc, that __devinitcont and friends will be removed.

I'm not sure why, actually.  I think I missed that dicussion.
