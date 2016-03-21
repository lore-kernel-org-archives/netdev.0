From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: AP firmware for TI wl1251 wifi chip (wl1251-fw-ap.bin)
Date: Mon, 21 Mar 2016 12:01:13 +0100
Message-ID: <20160321110113.GG8413@pali>
References: <201603200040.26045@pali>
 <878u1cglu3.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kev-l0cyMroinI0@public.gmane.org, "Andrew F. Davis" <afd-l0cyMroinI0@public.gmane.org>,
	Guy Mishol <guym-l0cyMroinI0@public.gmane.org>, Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	David Gnedt <david.gnedt-KfBRzk3UKwrZI3uBz1zZ2F6hYfS7NtTn@public.gmane.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <878u1cglu3.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 21 March 2016 12:35:32 Kalle Valo wrote:
> Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>=20
> > In linux-firmware repository [1] is missing AP firmware for TI wl12=
51=20
> > chip. There is only STA firmware wl1251-fw.bin which supports manag=
ed=20
> > and ad-hoc modes.
> >
> > For other TI wilink chips there are <CHIP>-ap.bin firmware files=20
> > (wl1271-fw-ap.bin and wl128x-fw-ap.bin) which support AP mode. But =
for=20
> > wl1251 firmware file with guessed name "wl1251-fw-ap.bin" is missin=
g.
> >
> > Do you have any idea what happened with AP firmware for ti wilink4=20
> > wl1251 wifi chip? Or where can be found? Guys from TI, can you help=
?
>=20
> It's a long time ago but IIRC wl1251 has not ever supported AP mode a=
nd
> wl1271 was the first one to support it. But I might be wrong of cours=
e.

Support for AP mode in current kernel driver wl1251.ko is missing, but =
I
could try to write it if there will be firmware for it.

According to some TI whitepaper about TI wilink4 devices (wl1251 and
wl1253) those devices have support for some Soft-AP mode.

--=20
Pali Roh=C3=A1r
pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
