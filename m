From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Tue, 27 Jul 2010 11:10:26 +0200
Message-ID: <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
References: <m139vd5sms.fsf_-_@fess.ebiederm.org> <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
	<AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	<m1vd87toy9.fsf@fess.ebiederm.org> <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	<1279822828.12439.24.camel@jlt3.sipsolutions.net> <20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net> <20100722185449.GB528@suse.de>
	<m1eievugon.fsf@fess.ebiederm.org> <20100726180941.GB4883@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49360 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914Ab0G0JKp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 05:10:45 -0400
Received: by ywh1 with SMTP id 1so489788ywh.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 02:10:44 -0700 (PDT)
In-Reply-To: <20100726180941.GB4883@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 26, 2010 at 20:09, Greg KH <greg@kroah.com> wrote:
>> Does this version of the change look less bleh worthy? =C2=A0The eff=
ect is
>> the same as my previous patch but the test is more abstract so the
>> effect is not strictly limited to /sys/class/net.
>
> What other class type has a namespace at this point in time?
> Essentially this is the same exact thing, just in a different format
> that obfuscates what you are really doing here.

The patch still looks broken, and does not belong into the core the
way it is done. We denied hacks like this for good reason. But
out-of-the-blue it was a bluetooth naming regression to fix in the
driver core? Interesting!

If someone is going to add namespaces to 'block' or 'input', the sysfs
layout will break, and userspace will be unable to handle the
resulting changes.

Kay
