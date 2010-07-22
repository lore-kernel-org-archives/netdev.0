From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
 regression
Date: Thu, 22 Jul 2010 11:28:27 -0700
Message-ID: <20100722182827.GA12821@suse.de>
References: <m1r5jdbobe.fsf@fess.ebiederm.org>
 <20100708230601.GB17002@kroah.com>
 <20100719133451.0862ca62.akpm@linux-foundation.org>
 <20100720201334.GA11991@suse.de>
 <m139vd5sms.fsf_-_@fess.ebiederm.org>
 <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
 <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
 <m1vd87toy9.fsf@fess.ebiederm.org>
 <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60651 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759826Ab0GVS2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 14:28:39 -0400
Content-Disposition: inline
In-Reply-To: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 08:20:28PM +0200, Johannes Berg wrote:
> On Thu, 2010-07-22 at 19:44 +0200, Kay Sievers wrote:
> 
> > Yes. The drivers are broken in its core use pattern, and enabling a
> > (non-common) new feature exposes this.
> 
> You've been saying this for a long time now, but I still don't buy it.
> 
> This stuff WORKED before. Now, years later, you're saying that it has a
> broken use pattern, and needs to be fixed. That's a pipe dream. In the
> real world, you can't deliberately break things because years later you
> decide that the use pattern that was working fine before is broken.

It worked only because no one realized that it was broken with the
DEPRECATED option enabled.  When that is enabled, it is broken, right?

Eric's changes to sysfs to add namespace support exposed this breakage.
That's not a reason to paper over the problem, but it should be driving
someone to fix it correctly, as has been pointed out a number of times
already.

thanks,

greg k-h
