From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Fri, 23 Jul 2010 01:03:28 +0200
Message-ID: <AANLkTim-PlI_LRCijJaDhl037xP-zwvzhN2R8iwnclwO@mail.gmail.com>
References: <20100621222938.GA20583@suse.de> <m1eig0dmhk.fsf@fess.ebiederm.org>
	<20100621231058.GA1066@suse.de> <m14ogwc4ou.fsf@fess.ebiederm.org>
	<20100622035631.GA3755@suse.de> <m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com> <20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	<m1zkxj27xp.fsf_-_@fess.ebiederm.org> <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	<m1vd87toy9.fsf@fess.ebiederm.org> <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	<1279822828.12439.24.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55199 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab0GVXDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 19:03:43 -0400
Received: by iwn7 with SMTP id 7so8270345iwn.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 16:03:43 -0700 (PDT)
In-Reply-To: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 20:20, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Thu, 2010-07-22 at 19:44 +0200, Kay Sievers wrote:
>
>> Yes. The drivers are broken in its core use pattern, and enabling a
>> (non-common) new feature exposes this.
>
> You've been saying this for a long time now, but I still don't buy it.

Well, than make different point. Stuff did not change for 3 years in a
row, and still does not need special handling of a specific subsystem
in the driver core.

> This stuff WORKED before.

Sure, and it still does.

> Now, years later, you're saying that it has a
> broken use pattern, and needs to be fixed. That's a pipe dream. In the
> real world, you can't deliberately break things because years later you
> decide that the use pattern that was working fine before is broken.

Yes, new stuff exposes old bugs, that's normal business. But there is
zero reason not to fix the problem then, but to introduce plain wrong
hacks in the wrong place.

Btw, I hope you guys stop the personal affronts in your mails, and
start focusing on a proper solution for the problem. I'll stop
responding if this will not go back to a discussion about technical
details.

Thanks,
Kay
