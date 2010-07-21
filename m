From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/2] Support untagged symlinks to tagged directories.
Date: Wed, 21 Jul 2010 13:36:05 -0700
Message-ID: <20100721203605.GA8369@kroah.com>
References: <20100622035631.GA3755@suse.de>
 <m1630q7x5v.fsf_-_@fess.ebiederm.org>
 <20100708211930.GA15385@kroah.com>
 <m1r5jdbobe.fsf@fess.ebiederm.org>
 <20100708230601.GB17002@kroah.com>
 <20100719133451.0862ca62.akpm@linux-foundation.org>
 <20100720201334.GA11991@suse.de>
 <m139vd5sms.fsf_-_@fess.ebiederm.org>
 <20100721190253.GA25494@kroah.com>
 <m18w544mer.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:57644 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803Ab0GUUgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 16:36:13 -0400
Content-Disposition: inline
In-Reply-To: <m18w544mer.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 01:20:28PM -0700, Eric W. Biederman wrote:
> Greg KH <greg@kroah.com> writes:
> 
> > On Tue, Jul 20, 2010 at 10:08:27PM -0700, Eric W. Biederman wrote:
> >> 
> >> Greg KH <gregkh@suse.de> writes:
> >> 
> >> > On Mon, Jul 19, 2010 at 01:34:51PM -0700, Andrew Morton wrote:
> >> >> On Thu, 8 Jul 2010 16:06:01 -0700
> >> >> Greg KH <greg@kroah.com> wrote:
> >> >> 
> >> >> > On Thu, Jul 08, 2010 at 03:28:53PM -0700, Eric W. Biederman wrote:
> >> >> > > Greg KH <greg@kroah.com> writes:
> >> >> > > 
> >> >> > > > With this patch, how does the existing code fail as the drivers aren't
> >> >> > > > fixed up?
> >> >> > > >
> >> >> > > > I like this change, just worried it will cause problems if it gets into
> >> >> > > > .35, without your RFC patch.  Will it?
> >> >> > > 
> >> >> 
> >> >> geethanks!
> >> >> 
> >> >> On the FC6 test box I have no networking.
> >> >
> >> > Ick.
> >> >
> >> > Eric, any ideas?
> >> 
> >> Yes.  I just found some time to test my fixes and things are looking
> >> good.  It really is just two one line fixes.
> >> 
> >> On the other part of this debug with SYSFS_DEPRECATED enabled it
> >> with mac80211_hwsim drivers works fine no problems.  I expect the
> >> bnep driver will also be fine.
> >> 
> >> What is affecting those two is arguably a bug in the non-deprecated
> >> sysfs mode.
> >> 
> >> Regardless here are my fixes.  I have split this into a patch for
> >> the warning and a patch for sysfs_delete_link.  Because at least
> >> the sysfs_delete_link code needs to make into 2.6.35 if we can.
> >
> > Do these patches obsolete the existing one I have in my tree entitled:
> > 	Subject: sysfs: Don't allow the creation of symlinks we can't remove
> > or are they on top of that one?
> 
> No. These patches are incremental on top of what you have.
> 
> In particular patch 1 fixes what is in 2.6.35-rc5, and patch 2
> fixes the additional check in:
> 'sysfs: Don't allow the creation of symlinks we can't remove'

Ok, thanks, I've now added them to my tree and will send them to Linus
in a day or so.

greg k-h
