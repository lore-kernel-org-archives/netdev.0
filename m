From: Filip Aben <f.aben@option.com>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 17:03:09 +0200
Message-ID: <1208271789.20681.45.camel@FWR-FLAB>
References: <20080414213238.GB28833@kroah.com>
	 <200804151525.57340.oliver@neukum.org> <1208268742.20681.29.camel@FWR-FLAB>
	 <200804151614.47977.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:5901 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760111AbYDOPDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 11:03:10 -0400
In-Reply-To: <200804151614.47977.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-04-15 at 16:14 +0200, Oliver Neukum wrote:
> Am Dienstag, 15. April 2008 16:12:22 schrieb Filip Aben:
> > 
> > On Tue, 2008-04-15 at 15:25 +0200, Oliver Neukum wrote:
> > > Am Montag, 14. April 2008 23:32:39 schrieb Greg KH:
> > > > Hi all,
> > > > 
> > > > Here's a patch that I have cleaned up for context only from Option that
> > > > is a USB serial / network device all in one.
> > > > 
> > > > I'd like to see this go into 2.6.26, so any review comments by anyone
> > > > who wishes to review any portion of this would be greatly apprecited.
> > > 
> > > The driver implements an ioctl to disable autosuspend. This seems
> > > unnecessary to me, as you can do that via sysfs, too. Is this included
> > > to work around permission problems? Can somebody explain?
> > > 
> > > 	Regards
> > > 		Oliver
> > 
> > This is added to support card firmware upgraders who will need to
> > disable suspend, even on (embedded) systems that don't have sysfs
> > mounted.
> 
> How do they enable autosuspend without sysfs?

Good point. No idea. I suppose it's easier to rely on something that
will always work, rather then making assumptions about suspend based on
whether sysfs is mounted or not.

( Wasn't there a kernel recently that had autosuspend enabled by
default ? )

Regards,

Filip-
