From: Greg KH <gregkh@suse.de>
Subject: Re: [Bugme-new] [Bug 16257] New: sysfs changes break hwsim and
 bnep drivers
Date: Mon, 21 Jun 2010 15:29:38 -0700
Message-ID: <20100621222938.GA20583@suse.de>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
 <20100621150826.762ac9f2.akpm@linux-foundation.org>
 <m1mxuodo0n.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41055 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab0FUWaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 18:30:03 -0400
Content-Disposition: inline
In-Reply-To: <m1mxuodo0n.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 03:22:32PM -0700, Eric W. Biederman wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Sun, 20 Jun 2010 11:23:02 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> >
> >> https://bugzilla.kernel.org/show_bug.cgi?id=16257
> >
> > Said to be a post-2.6.34 regression caused by the net namespaces changes.
> >
> > There's a massive thread there and I didn't work out whether it's
> > already been fixed?
> 
> The fix is pending.
> 
> The cause is understood.  Roughly we started caring about something
> being true in all cases and there are bugs where it is not.
> 
> The patch below is less pretty than I would like, but it is trivial
> and it fixes the problem in all cases, and in exactly the cases that
> are broken today.
> 
> I have received no feedback since I posted it.  Right now there are no
> viable alternatives on the table for the 2.6.35 timeframe.  The only
> suggested alternatives is to rewrite the affected drivers sysfs
> support and fix the driver core so that rewrite is actually possible.

I _really_ do not like this patch.

The correct thing is to fix the modules that are affected, and that's
only the wireless testing module, right?  Or is there something else?

And if that code is properly converted to a bus, what needs to change in
the driver core?

thanks,

greg k-h
