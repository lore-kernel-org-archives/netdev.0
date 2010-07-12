From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] mac80211_hwsim: No parent is better than an illegimate one.
Date: Mon, 12 Jul 2010 07:23:09 -0700
Message-ID: <m11vb8u6cy.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<m1zky26iaw.fsf_-_@fess.ebiederm.org>
	<1278917200.3667.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	"Greg KH \<gregkh\@suse.de\> netdev" <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57929 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359Ab0GLOXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 10:23:33 -0400
In-Reply-To: <1278917200.3667.1.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Mon\, 12 Jul 2010 08\:46\:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Thu, 2010-07-08 at 09:37 -0700, Eric W. Biederman wrote:
>> Don't call SET_IEEE80211_DEV.  This weakens the connections between
>> the phy files in sysfs slightly but otherwise it makes the driver work
>> in the face of tagged sysfs support.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>> 
>> Johannes does this change look usable?
>
> It'll probably work, but anything in userspace relying on it will fail,
> and you'll have some unused virtual devices in sysfs?

Well anything in userspace that isn't mac80211_hwsim specific will
likely already fail because the format of the link is different for
mac80211_hwsim then for every other wireless device.

> Not too keen on it, but if we really can't fix it ....

Perhaps.  I'm not familiar enough with the details of the device layer
to promise an eta on anything like that.

Eric
