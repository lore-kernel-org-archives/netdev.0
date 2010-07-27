From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
 regression
Date: Tue, 27 Jul 2010 06:49:04 -0700
Message-ID: <20100727134904.GA4994@kroah.com>
References: <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
 <m1vd87toy9.fsf@fess.ebiederm.org>
 <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
 <20100722182827.GA12821@suse.de>
 <1279823801.12439.31.camel@jlt3.sipsolutions.net>
 <20100722185449.GB528@suse.de>
 <m1eievugon.fsf@fess.ebiederm.org>
 <20100726180941.GB4883@kroah.com>
 <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:53881 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753673Ab0G0Nt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 09:49:57 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 11:10:26AM +0200, Kay Sievers wrote:
> On Mon, Jul 26, 2010 at 20:09, Greg KH <greg@kroah.com> wrote:
> >> Does this version of the change look less bleh worthy? =A0The effe=
ct is
> >> the same as my previous patch but the test is more abstract so the
> >> effect is not strictly limited to /sys/class/net.
> >
> > What other class type has a namespace at this point in time?
> > Essentially this is the same exact thing, just in a different forma=
t
> > that obfuscates what you are really doing here.
>=20
> The patch still looks broken, and does not belong into the core the
> way it is done. We denied hacks like this for good reason. But
> out-of-the-blue it was a bluetooth naming regression to fix in the
> driver core? Interesting!
>=20
> If someone is going to add namespaces to 'block' or 'input', the sysf=
s
> layout will break, and userspace will be unable to handle the
> resulting changes.

When that happens, I'm sure Eric will be willing to fix up any problems
that are found as he is the one that insisted on pushing it to Linus
around our objections.

Right Eric?

And Eric, where are you working on the "real" patches to solve the
problems of the bnet and wireless driver problems so we can remove this
check from the driver core as soon as possible?  Any idea when they wil=
l
be done?

thanks,

greg k-h
