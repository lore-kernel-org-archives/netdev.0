From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
 regression
Date: Thu, 22 Jul 2010 20:36:41 +0200
Message-ID: <1279823801.12439.31.camel@jlt3.sipsolutions.net>
References: <m1r5jdbobe.fsf@fess.ebiederm.org>
	 <20100708230601.GB17002@kroah.com>
	 <20100719133451.0862ca62.akpm@linux-foundation.org>
	 <20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	 <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
	 <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	 <m1vd87toy9.fsf@fess.ebiederm.org>
	 <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	 <20100722182827.GA12821@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:33708 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab0GVShY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 14:37:24 -0400
In-Reply-To: <20100722182827.GA12821@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-22 at 11:28 -0700, Greg KH wrote:

> It worked only because no one realized that it was broken with the
> DEPRECATED option enabled.  When that is enabled, it is broken, right?

I'm pretty sure I always had that enabled, and never had issues. Can't
test right now since I don't have that option back yet in the tree I'm
using.

> Eric's changes to sysfs to add namespace support exposed this breakage.
> That's not a reason to paper over the problem, but it should be driving
> someone to fix it correctly, as has been pointed out a number of times
> already.

I'm just contesting that that someone should be me. I don't think you
get to blame driver developers for doing something that worked and
solved the problem they needed to solve. sysfs is largely opaque to most
of us already, and it now sure feels like Kay decided to change the
rules underneath the code in saying "this was wrong all along".

johannes

