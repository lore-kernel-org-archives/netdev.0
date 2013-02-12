From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: decnet: /proc/sys/net/decnet sysctl entries disappear
Date: Tue, 12 Feb 2013 01:01:43 +0000
Message-ID: <1360630903.2701.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov>
	 <1360629988.2701.23.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Larry Baker <baker@usgs.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36302 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674Ab3BLBB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 20:01:58 -0500
In-Reply-To: <1360629988.2701.23.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I'm making more than the usual rate of errors today; let me
correct myself:

On Tue, 2013-02-12 at 00:46 +0000, Ben Hutchings wrote:
> Please read and follow the advice in Documentation/SubmittingPatches,
> including in particular about the Developer's Certificate of Origin.
> 
> On Tue, 2013-02-12 at 00:26 +0000, Larry Baker wrote:
> [...]
> > Other changes are:
> > 
> > . Updated banner
> > . DECnet device up/down KERN_INFO messages
> > . debug module parameter
> > . NETDEV_UP/DOWN KERN_DEBUG messages if (debug & 8)
> > . dn_route.c uses dn_hiord[ETH_ALEN] in dn_dev.c
> 
> Each patch should do one thing.  So send one patch with the sysctl
> patch, and additional patches for the other changes.

Each patch should do one thing.  So send one patch with the sysctl fix,
and additional patches for the other changes.

> > --- original/net/decnet/af_decnet.c
> > +++ patched/net/decnet/af_decnet.c
> > @@ -1,2 +1 @@
> > -
> >  /*
> > @@ -42,2 +41,5 @@
> >   *                          prepare for sendpage etc.
> > + *            Larry Baker : Register static /proc/sys/net/decnet entries before
> > + *                          dynamic /proc/sys/net/decnet/conf entries in
> > + *                          dn_dev_init().
> >   */
> [...]
> 
> There is no log changes in file headers; this information is all
> recorded by the git version control system.

There is no need to log changes in file headers; this information is all
recorded by the git version control system.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
