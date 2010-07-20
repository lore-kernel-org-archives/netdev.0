From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't
	remove
Date: Tue, 20 Jul 2010 13:13:34 -0700
Message-ID: <20100720201334.GA11991@suse.de>
References: <20100621222938.GA20583@suse.de> <m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de> <m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de> <m1630q7x5v.fsf_-_@fess.ebiederm.org> <20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org> <20100708230601.GB17002@kroah.com> <20100719133451.0862ca62.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46019 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932507Ab0GTUY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 16:24:26 -0400
Content-Disposition: inline
In-Reply-To: <20100719133451.0862ca62.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 19, 2010 at 01:34:51PM -0700, Andrew Morton wrote:
> On Thu, 8 Jul 2010 16:06:01 -0700
> Greg KH <greg@kroah.com> wrote:
> 
> > On Thu, Jul 08, 2010 at 03:28:53PM -0700, Eric W. Biederman wrote:
> > > Greg KH <greg@kroah.com> writes:
> > > 
> > > > With this patch, how does the existing code fail as the drivers aren't
> > > > fixed up?
> > > >
> > > > I like this change, just worried it will cause problems if it gets into
> > > > .35, without your RFC patch.  Will it?
> > > 
> > > It don't expect this patch to be worse than where we are current at.
> > > Network devices are renamed, and come and go enough that both the
> > > mac80211_hwsim and the bnep driver are currently unusable with a
> > > failure only the rename and remove.
> > > 
> > > This patch simply moves the failure into creation where we are a little more
> > > prepared to deal with problems, and this patch is limited to mac80211_hwsim,
> > > bnep, and any hypothetically undiscovered other network devices that
> > > have the same problem.
> > > 
> > > mac80211_hwsim with just this patch becomes somewhat usable as it's primary
> > > network device gets registered and the module can be loaded and unloaded.  It
> > > just doesn't create the wlan0 and wlan1 interfaces for the wifi interfaces.
> > 
> > Fair enough, I've commited it now, let's see what happens :)
> 
> geethanks!
> 
> On the FC6 test box I have no networking.

Ick.

Eric, any ideas?

