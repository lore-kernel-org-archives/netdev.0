From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RESEND PATCH 1/3] rfkill: Create "rfkill-airplane-mode" LED
 trigger
Date: Mon, 13 Jun 2016 23:01:09 +0200
Message-ID: <20160613210109.GA9303@amd>
References: <1462199948-6424-1-git-send-email-jprvita@endlessm.com>
 <1462199948-6424-2-git-send-email-jprvita@endlessm.com>
 <20160504072936.GB17045@amd>
 <1463045572.13313.21.camel@sipsolutions.net>
 <20160519071639.GB17077@amd>
 <1465476194.3442.21.camel@sipsolutions.net>
 <CA+A7VXXP3TYuk4Vvgc8YvxPFo06GG6WpyLJS+2vMLzr0iKQgsA@mail.gmail.com>
 <20160613190048.GA17101@amd>
 <CA+A7VXXOfN1Td2T6uiunWZMS4gvS5sHDzPiDp9VEdx+OPJpSmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: =?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+A7VXXOfN1Td2T6uiunWZMS4gvS5sHDzPiDp9VEdx+OPJpSmA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2016-06-13 15:59:35, Jo=E3o Paulo Rechi Vita wrote:
> On 13 June 2016 at 15:00, Pavel Machek <pavel@ucw.cz> wrote:
> > Hi!
> >
> >> > Jo=E3o, that means you should send a patch to add the ::rfkill s=
uffix.
> >> >
> >>
> >> IMO "airplane" (or maybe "airplane-mode") is a better suffix, as i=
t
> >> reflects the label on the machine's chassis. I'll name it
> >> "asus-wireless::airplane" and send this through platform-drivers-x=
86,
> >> as this is now contained in the platform-drivers-x86 subsystem. Th=
anks
> >> Johannes for your patience and help designing and reviewing the rf=
kill
> >> changes, even if not all of them made it through in the end. And
> >> thanks everyone else involved for the feedback.
> >
> > Actually, I'd do '::rfkill', for consistency with other places in
> > /sys.
> >
> > /sys/devices/platform/thinkpad_acpi/rfkill/rfkill1/name
> > /sys/class/rfkill
> > /sys/module/rfkill
> >
>=20
> If we use "rfkill" as a suffix, how do you expect userspace to be abl=
e
> to differentiate between a LED that indicates airplane-mode (LED ON
> when all radios are OFF) and a LED that indicates the state of a
> specific radio like WiFi or Bluetooth (LED ON when that specific radi=
o
> is ON)? If we're going this route we should provide meaningful
> information here.

'::airplane' has same problem, no?

If you want to distinguish that, maybe you can do '::rfkill' for
everything vs '::rfkill-wifi' for wifi-only and '::rfkill-bt' for
bluetooth...

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
