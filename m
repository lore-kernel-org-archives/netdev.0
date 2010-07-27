From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename regression
Date: Tue, 27 Jul 2010 11:44:45 -0700
Message-ID: <m1zkxcg3xe.fsf@fess.ebiederm.org>
References: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	<20100726180941.GB4883@kroah.com>
	<AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org>
	<AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
	<20100727183624.GB30363@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>, Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52257 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662Ab0G0Sou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 14:44:50 -0400
In-Reply-To: <20100727183624.GB30363@kroah.com> (Greg KH's message of "Tue\, 27 Jul 2010 11\:36\:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

> On Tue, Jul 27, 2010 at 08:24:31PM +0200, Kay Sievers wrote:
>> On Tue, Jul 27, 2010 at 20:17, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> > Greg KH <greg@kroah.com> writes:
>> 
>> > Let me say this again clearly.
>> >
>> > class -> bus BROKEN
>> >
>> > In the case of bluetooth it would require changing /sys/class/bluetooth
>> > to /sys/bus/bluetooth. ??Which is user visible in the worst possible
>> > way and quick google search confirmed it will break user space scripts.
>> 
>> Clearly, we even have a compat API for that, and nothing would break.
>> If needed, a bus can create compat class links. Did you even check
>> with the bluetooth guys, last time I talked to them, they have been
>> totally fine with such a change.

Hmm.  It appears I missed the compat API in my review of the bus code.
Could I get a pointer?

> Yeah, I even had patches that almost did this work a few years ago.
> Most of the bluetooth class stuff (if not all of it) can be safely moved
> to debugfs, as it's just debug information.

That change merged about March, so that is no longer an issue.

Eric
