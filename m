From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: bisected: 2.6.28-rc broke my iwl4965 wireless
Date: Mon, 27 Oct 2008 17:41:34 +0100
Message-ID: <1225125694.3796.28.camel@johannes.berg>
References: <20081025222208.1d2a2c8b@infradead.org>
	 <20081027163812.GB6377@tesla> (sfid-20081027_173820_318230_ACAD18C7)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8HvvIqjmKeRLps5zwWdp"
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081027163812.GB6377@tesla> (sfid-20081027_173820_318230_ACAD18C7)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-8HvvIqjmKeRLps5zwWdp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-10-27 at 09:38 -0700, Luis R. Rodriguez wrote:

> > 2.6.28-rc1 broke my (intel 4965) wireless, and I've bisected it down to
> > the commit below..... something's fishy with this...

> Additionally if the old behaviour is desired for now (until distributions
> catch up and add CRDA) CONFIG_WIRELESS_OLD_REGULATORY can be enabled
> and you'll get the old behaviour of defaulting to country "US".

Luis, Arjan's bug is actually indicative of a driver bug, he told me
that he actually runs into driver message like "cannot set TX power
while scanning", and it's fixed by setting WIRELESS_OLD_REGULATORY for
some reason. Arjan, do you still have the actual messages you get when
it fails? That's a separate bug we should address, rather than relying
on it not happening with the old regulatory setting.

johannes

--=-8HvvIqjmKeRLps5zwWdp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBe87AAoJEKVg1VMiehFY2AsQAIEMsK0HKHWQ3k1aRyETRkJV
OiGqANDU9i0nCGO7Y4TWZqJzUJtu1/vEdbfwhW6ZXPdsT2WKwrmHVsAX0PnpZH+Q
OZDVRF/eePx0e+gpUiJVnmg/KHfRtd5cYiXt1tOQZejvSYAU3pRc7Yp0GGub/HoY
gG0q7Q6HarW+zNCrPqQNDxa/Ug0hlaXc3EAl8SD/CWe0li5V35ZkDnay1QR+Z35K
EPVCKDvMUV2+w4lI9cvSZ2+epbWeYqQ1xgxiv9GP8KIzJT1LqDRS0yeuMHVNq01S
t7BaTfaVPp83mUkWqaSXdgJ6i6r4OQb6ZmpcLdATmqXP+EMSRCq3YcdJThMuWqyy
6xUoyGx3dQyJw+gGJxs17gbARILMGMX8lhNPUBuN+hhl07n0I+M4W4H0IXbF/PTL
syIceJhzOL5Qh5kvngLEM/yEGEgDj5VfFzKb+AR5uFbiHCwWx3KYvZ5csVsZWSzm
b5DA/RGGUNeV8owa6g9/1Aa5GNMT3yarFNe4GxxVpiY/di36tSwv8EWG3BFlxjLU
TTbjChnwkBhgFxKRAA5Pk5g60Kyqznukfn4NDMBkLAy15goBGt/8uCI/f85HrgdL
BOrH8oBgDFFTxtXzEhGc2bDWk9Ue3y/cUuRZxh6odCYTCklXaihc7n6rDs5gJGlh
hadv/GfPgJp+l/k+i601
=VlGa
-----END PGP SIGNATURE-----

--=-8HvvIqjmKeRLps5zwWdp--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
