From: Greg KH <gregkh@suse.de>
Subject: Re: [Bugme-new] [Bug 16257] New: sysfs changes break hwsim and
 bnep drivers
Date: Mon, 21 Jun 2010 16:10:58 -0700
Message-ID: <20100621231058.GA1066@suse.de>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
 <20100621150826.762ac9f2.akpm@linux-foundation.org>
 <m1mxuodo0n.fsf@fess.ebiederm.org>
 <20100621222938.GA20583@suse.de>
 <m1eig0dmhk.fsf@fess.ebiederm.org>
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
Received: from cantor2.suse.de ([195.135.220.15]:59734 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575Ab0FUXLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 19:11:08 -0400
Content-Disposition: inline
In-Reply-To: <m1eig0dmhk.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 03:55:35PM -0700, Eric W. Biederman wrote:
> Greg KH <gregkh@suse.de> writes:
> 
> > I _really_ do not like this patch.
> >
> > The correct thing is to fix the modules that are affected, and that's
> > only the wireless testing module, right?  Or is there something else?
> >
> > And if that code is properly converted to a bus, what needs to change in
> > the driver core?
> 
> The usb bnep driver.

Odd, what is bnep doing differently here from all other network drivers?
Is it trying to stack the bluetooth class in the middle somehow?
Shouldn't this be easy to fix up in the driver itself?

thanks,

greg k-h
