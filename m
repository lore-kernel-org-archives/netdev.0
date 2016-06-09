From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RESEND PATCH 1/3] rfkill: Create "rfkill-airplane-mode" LED
 trigger
Date: Thu, 09 Jun 2016 14:43:14 +0200
Message-ID: <1465476194.3442.21.camel@sipsolutions.net>
References: <1462199948-6424-1-git-send-email-jprvita@endlessm.com>
	 <1462199948-6424-2-git-send-email-jprvita@endlessm.com>
	 <20160504072936.GB17045@amd> <1463045572.13313.21.camel@sipsolutions.net>
	 <20160519071639.GB17077@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160519071639.GB17077@amd>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-05-19 at 09:16 +0200, Pavel Machek wrote:

> > In the original situation, without these patches, userspace has to
> > have a list of all LEDs that are supposed to indicate airplane
> > mode.
> Well, that's situation for many LEDs.

That doesn't make it a *good* situation though.

> > With this patch only (without patch 2/3), userspace can look up the
> > default trigger, but then has to change it, causing the necessary
> > information to be lost immediately when you actually use it - that
> > also seems like a bad idea.
> We should not store "what kind of led this is" in a trigger.=20

That's pretty much what I'm arguing though.

> LED
> subsystem seems to use suffix of LED name to do that. So if we
> standartize, lets say "::rfkill" suffix for this, it should work and
> follow existing practice.
[...]
> There is one -- suffix in the LED name.

I don't really think that's a good way, and it doesn't seem to be used
universally, but I suppose it's good enough.

Jo=C3=A3o, that means you should send a patch to add the ::rfkill suffi=
x.

And Pavel should send a patch to document the practice and the existing
suffixes with their meaning ;-)

johannes
