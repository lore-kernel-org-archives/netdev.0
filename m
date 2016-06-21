From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RESEND PATCH 1/3] rfkill: Create "rfkill-airplane-mode" LED
 trigger
Date: Tue, 21 Jun 2016 11:35:38 +0200
Message-ID: <1466501738.3170.10.camel@sipsolutions.net>
References: <1462199948-6424-2-git-send-email-jprvita@endlessm.com>
 <20160504072936.GB17045@amd>
 <1463045572.13313.21.camel@sipsolutions.net>
 <20160519071639.GB17077@amd>
 <1465476194.3442.21.camel@sipsolutions.net>
 <CA+A7VXXP3TYuk4Vvgc8YvxPFo06GG6WpyLJS+2vMLzr0iKQgsA@mail.gmail.com>
 <20160613190048.GA17101@amd>
 <CA+A7VXXOfN1Td2T6uiunWZMS4gvS5sHDzPiDp9VEdx+OPJpSmA@mail.gmail.com>
 <20160613210109.GA9303@amd>
 <CA+A7VXWdt16KHNx0n9jnpimCvN9dV38kb6smTbGWaJYo5VYcOQ@mail.gmail.com>
	 <20160613212116.GA10478@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160613212116.GA10478@amd>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-06-13 at 23:21 +0200, Pavel Machek wrote:
>=C2=A0
> (Actually, "::wifi" is super confusing, I'd expect that to be a led
> that blinks when wifi is active.)

Agree with that, yeah, that'd be confusing.

> Well... "airplane" is quite confusing. I'd we use "rfkill" for
> disabling radios, and I believe we should stick with that.
>=20
> But small problem might be polarity. You may need both "::rfkill" and
> "::not-rfkill".

I'd argue that "airplane" matches better what you're likely to find on
the chassis of the system.

In either case I think the suffixes should be documented, for both
future kernel and application developers.

johannes
