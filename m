From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RESEND PATCH 1/3] rfkill: Create "rfkill-airplane-mode" LED
 trigger
Date: Thu, 12 May 2016 11:32:52 +0200
Message-ID: <1463045572.13313.21.camel@sipsolutions.net>
References: <1462199948-6424-1-git-send-email-jprvita@endlessm.com>
	 <1462199948-6424-2-git-send-email-jprvita@endlessm.com>
	 <20160504072936.GB17045@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160504072936.GB17045@amd>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-05-04 at 09:29 +0200, Pavel Machek wrote:
>=C2=A0
> If userspace wants to control the manually, it can do just that --
> control it manually. There should not be a need to "override the
> default policy".

I'm still not buying this.

In the original situation, without these patches, userspace has to have
a list of all LEDs that are supposed to indicate airplane mode.

With this patch only (without patch 2/3), userspace can look up the
default trigger, but then has to change it, causing the necessary
information to be lost immediately when you actually use it - that also
seems like a bad idea.

With the patches, the userspace that cares can also concentrate on
something it already *does* - i.e. dealing with the rfkill API - and
let the rest of the situation be sorted out in itself.


Now, if the LED subsystem had a really good way of specifying LED
intent, and it was widely used, and rfkill didn't already concern
itself with the rfkill status of all devices ... yeah maybe this
wouldn't be needed. As it stands, I still think this is the best way
forward.

johannes
