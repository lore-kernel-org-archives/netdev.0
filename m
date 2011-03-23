From: Michal Nazarewicz <mnazarewicz@gmail.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Thu, 24 Mar 2011 00:17:34 +0100
Message-ID: <8762r9l94h.fsf@erwin.mina86.com>
References: <4D79F068.2080009@linaro.org> <201103232035.18232.arnd@arndb.de>
	<AANLkTim7hPfTv3gDYnh+jGxHBg0OvX=r1FKYoHnH7H_o@mail.gmail.com>
	<201103232057.18150.arnd@arndb.de>
	<20110323125958.76285c0f.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Arnd Bergmann <arnd@arndb.de>,
	=?utf-8?Q?Micha=C5=82?= Nazarewicz <mnazarewicz@gmail.com>,
	broonie@opensource.wolfsonmicro.com,
	lkml <linux-kernel@vger.kernel.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Greg KH <greg@kroah.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, grant.likely@secretlab.ca,
	Linux USB list <linux-usb@vger.kernel.org>,
	andy.green@linaro.org, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	roger.quadros@nokia.com,
	Jaswinder Singh <jaswinder.singh@linaro.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110323125958.76285c0f.rdunlap@xenotime.net> (Randy Dunlap's
	message of "Wed, 23 Mar 2011 12:59:58 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

>>>>>> @@ -97,6 +97,8 @@ struct driver_info {
>>>>>>
>>>>>>  #define FLAG_LINK_INTR       0x0800          /* updates link (carri=
er) status */
>>>>>>
>>>>>> +#define FLAG_PTP     0x1000          /* maybe use "usb%d" names */

>>>> On Wednesday 23 March 2011 19:46:50 Greg KH wrote:
>>>>> "PTP"?  What does that stand for?

>>> On Mar 23, 2011 8:36 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:
>>>> point-to-point, I'll improve the comment to spell it out when
>>>> I send the fixed version.

>> On Wednesday 23 March 2011 20:53:13 Micha=C5=82 Nazarewicz wrote:
>>> I think P2P could be better.

> On Wed, 23 Mar 2011 20:57:18 +0100 Arnd Bergmann wrote:
>> Yes, good idea.

Randy Dunlap <rdunlap@xenotime.net> writes:
> that's peer-to-peer.
>
> OTOH, I knew that PTP was point-to-point.

It can be any of that, depending on context.  For me PTP is more like
Picture Transport Protocol, whereas "2" between two letters is usually
"to".

Just my two cents though, no strong feelings or anything.

=2D-=20
Best regards,                                          _     _
 .o. | Liege of Serenly Enlightened Majesty of       o' \,=3D./ `o
 ..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
 ooo +-<mina86-mina86.com>-<jid:mina86-jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAk2Kf5UACgkQUyzLALfG3x601wCgpGmM9j0n6j/U8nARWZ90rhM7
pR0AoIvKT6gfV54cBg3c6eB2RQI0rOzw
=1sLy
-----END PGP SIGNATURE-----
--=-=-=--
