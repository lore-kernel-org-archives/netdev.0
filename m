From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/2] Support untagged symlinks to tagged directories.
Date: Tue, 20 Jul 2010 22:08:27 -0700
Message-ID: <m139vd5sms.fsf_-_@fess.ebiederm.org>
References: <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com>
	<20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33366 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab0GUFIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 01:08:52 -0400
In-Reply-To: <20100720201334.GA11991@suse.de> (Greg KH's message of "Tue\, 20 Jul 2010 13\:13\:34 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Greg KH <gregkh@suse.de> writes:

> On Mon, Jul 19, 2010 at 01:34:51PM -0700, Andrew Morton wrote:
>> On Thu, 8 Jul 2010 16:06:01 -0700
>> Greg KH <greg@kroah.com> wrote:
>> 
>> > On Thu, Jul 08, 2010 at 03:28:53PM -0700, Eric W. Biederman wrote:
>> > > Greg KH <greg@kroah.com> writes:
>> > > 
>> > > > With this patch, how does the existing code fail as the drivers aren't
>> > > > fixed up?
>> > > >
>> > > > I like this change, just worried it will cause problems if it gets into
>> > > > .35, without your RFC patch.  Will it?
>> > > 
>> 
>> geethanks!
>> 
>> On the FC6 test box I have no networking.
>
> Ick.
>
> Eric, any ideas?

Yes.  I just found some time to test my fixes and things are looking
good.  It really is just two one line fixes.

On the other part of this debug with SYSFS_DEPRECATED enabled it
with mac80211_hwsim drivers works fine no problems.  I expect the
bnep driver will also be fine.

What is affecting those two is arguably a bug in the non-deprecated
sysfs mode.

Regardless here are my fixes.  I have split this into a patch for
the warning and a patch for sysfs_delete_link.  Because at least
the sysfs_delete_link code needs to make into 2.6.35 if we can.

Eric
