From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
	restart.
Date: Sun, 21 Sep 2008 21:14:04 +0200
Message-ID: <1222024444.3023.53.camel@johannes.berg>
References: <20080921172316.GA6306@2ka.mipt.ru>
	 <20080921110422.1d010b96@infradead.org>
	 <20080921182835.GA11473@2ka.mipt.ru>
	 <20080921113513.16677c4e@infradead.org>
	 <20080921190050.GA20484@2ka.mipt.ru> (sfid-20080921_210242_482049_43D40C50)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-P4pWs/jhFbewJryBGqCD"
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080921190050.GA20484-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org> (sfid-20080921_210242_482049_43D40C50)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-P4pWs/jhFbewJryBGqCD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-09-21 at 23:00 +0400, Evgeniy Polyakov wrote:

> Do you want me to implement ipw2100 driver as a big work structure
> which will run ipw2100_init()/wait/ipw2100_exit() in a loop?
> And that will be the fix suggested by Intel? That would explain a lot.

I think what Arjan is saying is that it would be better to put pressure
on the responsible folks (I don't think Arjan is anywhere near them at
all) if you'd put in a WARN_ON() for this error and that would make the
top entry on kerneloops.org all the time... And additionally put in a
workaround for yourself for now.

And can we keep the flames off this list please? That comment from Wei
Weng was absolutely uncalled for, and inciting a flamewar (as you have
already blogged) was not really productive either.

johannes

--=-P4pWs/jhFbewJryBGqCD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI1pz3AAoJEKVg1VMiehFYFTUQAMXGPaS6Ec7oPwiOp2SGm2Om
o8hTLtj+ZpIkBVdVLrm+gukxsEh3NENUdBHWaRuA5BKeOL8yXzTAFoBxGp6RhJfU
4wLIY0ju3BQIpnau6a1LIe5PHaQXKUs/B70zfrY7WC+/bEbUCB5cBYklhzIVCtih
PjSbtE4Ljrv4Mb8AzNVNm6ZKvRZ57HA0gycWirziD5LbbbssIvupIJ3mXA5jtmJ6
s8ljlkcp2UXT+jTDaFHUeBhzNVYnJQ+M+F2E0ZMW9/v/S5an+dq5zVFqQ7f/Icp5
Pr6W6ZwGjfx9w+BQuvKMKtT+8UeEuRzAcSFi23x1BVtV776/ZoH9J5t6SnhXZpJ9
hNCxruP8vdlP9bp6izJlrSNA3qEDhnxwZQqbr1h6e65uzcwNO/d9qTXgzpu0MDpp
9WX6j6A5VmHTQ2R+YGRXRSRiSKsXa5ADLqcQncMJs7jIgfoHHtXGfleUhy/3JTU4
iD9rBXh5sHoviIzmtfaj72JGeflPjDOvOWdEBTfL3KuVfVcYN4PaAGAT96yXUwpp
SB7129nIDLDwbu/mm+7TkIHCRK2q/mvz4e499uiLt6eIhYmopXKmS/+KK7SLRDi1
nqu3ztZhSJrKceHpjMlgaadVRv3oTi3xADwhsm6sW3xuCko8uJs33jS3m7oN4PuS
1U9xyn52TP88ON++vREd
=i2O6
-----END PGP SIGNATURE-----

--=-P4pWs/jhFbewJryBGqCD--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
