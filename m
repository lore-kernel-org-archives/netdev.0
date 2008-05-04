From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 18:03:26 +0200
Message-ID: <1209917006.3753.2.camel@johannes.berg>
References: <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 <1209892489.6210.56.camel@johannes.berg>
	 <20080504094444.GA541@gondor.apana.org.au>
	 <1209894754.6210.58.camel@johannes.berg>
	 <1209900355.6210.64.camel@johannes.berg>
	 <1209904088.4065.11.camel@johannes.berg>
	 <20080504124542.GA1455@gondor.apana.org.au>
	 <1209909990.3753.0.camel@johannes.berg>
	 (sfid-20080504_160619_267031_C8D61782)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VDIlIrNuz2WeYKL9qk1e"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209909990.3753.0.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080504_160619_267031_C8D61782)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-VDIlIrNuz2WeYKL9qk1e
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 16:06 +0200, Johannes Berg wrote:
> > There are three ways out of this.  You could have your own cache
> > (I haven't looked at your headers so I don't know whether that
> > makes sense), have no cache at all, or add a new field that gets
> > added to hard_header_len for the purposes of calculating head
> > room.
>=20
> I tried the last option, patch below, didn't quite work out yet, but I
> got:
>=20
> [  256.241496] KERNEL: assertion (!atomic_read(&sk->sk_wmem_alloc))
> failed at net/packet/af_packet.c (225)

Except for that, the patch works fine with mac80211 setting the new
netdev fields. I still get lots of reallocations though because I get a
lot of cloned packets, not sure why.

johannes

--=-VDIlIrNuz2WeYKL9qk1e
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB3eTKVg1VMiehFYAQJL1RAAnBugK+Fyyy5rdhWUCT4hBzS50xQGenD8
bgILSKroo7HbOaoZ7jVsIK/A1hcLtD95t/+PU4Cv1Sz0O+5KA+jtroslffL/7oun
1jP3pwb5NU4PRHMR8sG8LuC6fPH+HvhZjLMThYPZTMKFggEgyQIOOJGThl9qbBY0
N/HfX20IqDJtdYOkgz4wg44tthMPzIdRUP1aByuNvHxqJB9pRKrJSodj2K7ke6qE
EchsMICch3sxKPw8a9NY3oDom2Rn0k7vJKmGn/6zncfUJzRGOEvGCrc19xg28glb
bnprpWhmbKMc3ATLaBhoswr2Qm9DeooQ0UkTRulshAhhW+EOy0PZXMqJljHDxSFk
14oh3qdby40srnpJDq+w3gNv0FBcZCQSIJtv8+3Kvo3irRCgwl7a6CnU3ZIx3Nm0
1uqRrz4RT5sRUP3IjAhtxcY+HUzeFpfxHzQH6ZM4pIP61AF0I8hLytLZZHrTQ4kG
u+hv2pex8ldSUjwkXiT0JcVXwbTaDGlVgVh68bd0QR7ceauwM/haw3cZoATMHkdU
lUsjHiqQo5u3ojb67twsL+R7mKGGUZdE2CzM4Qw5RAKOhPsGa//Td6JRsoIH5yQN
NNtnUVIyYKIgswPRfUOFzhXjt7M0kfVXcswdYhEMjssdvyob/AowgaddSnH15cvt
9yYjhQUYd4o=
=VYyy
-----END PGP SIGNATURE-----

--=-VDIlIrNuz2WeYKL9qk1e--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
