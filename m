From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Tue, 27 Jul 2010 11:36:24 -0700
Message-ID: <20100727183624.GB30363@kroah.com>
References: <1279822828.12439.24.camel@jlt3.sipsolutions.net> <20100722182827.GA12821@suse.de> <1279823801.12439.31.camel@jlt3.sipsolutions.net> <20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org> <20100726180941.GB4883@kroah.com> <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com> <20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org> <AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:47974 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284Ab0G0SgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 14:36:12 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 08:24:31PM +0200, Kay Sievers wrote:
> On Tue, Jul 27, 2010 at 20:17, Eric W. Biederman <ebiederm@xmission.com> wrote:
> > Greg KH <greg@kroah.com> writes:
> 
> > Let me say this again clearly.
> >
> > class -> bus BROKEN
> >
> > In the case of bluetooth it would require changing /sys/class/bluetooth
> > to /sys/bus/bluetooth. ??Which is user visible in the worst possible
> > way and quick google search confirmed it will break user space scripts.
> 
> Clearly, we even have a compat API for that, and nothing would break.
> If needed, a bus can create compat class links. Did you even check
> with the bluetooth guys, last time I talked to them, they have been
> totally fine with such a change.

Yeah, I even had patches that almost did this work a few years ago.
Most of the bluetooth class stuff (if not all of it) can be safely moved
to debugfs, as it's just debug information.

I should dig them out and refresh them in my spare time :)

thanks,

greg k-h
