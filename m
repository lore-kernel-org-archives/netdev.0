From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Tue, 18 Dec 2007 13:42:05 +0100
Message-ID: <1197981725.4885.114.camel@johannes.berg>
References: <1197483844.6558.158.camel@johannes.berg>
	 <20071213204933.GD3083@tuxdriver.com>
	 <1197634443.16079.36.camel@johannes.berg> <20071218042253.GC5698@jm.kir.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-srbYuINnusWYGVEIPzR6"
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071218042253.GC5698-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-srbYuINnusWYGVEIPzR6
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > I think in theory all eapol frames are sent to the PAE group address,
> > but I have no idea which of the checks would be more efficient. It seem=
s
> > that the first could be optimised a lot because it's constant too...
>=20
> They are not.. PAE group address is used for all EAPOL frames in
> non-shared media LANs (e.g., wired Ethernet switch), but IEEE 802.11
> uses the specific MAC address of the PAE since it is a shared media LAN
> (i.e., the frames are between the unicast MAC address of the non-AP
> STA/Supplicant and AP/Authenticator).=20

If that's how it's specified, ok, but I think it's not strictly
necessary because the AP is addressed already by the BSSID, no?

> If we end up having to drop the
> PAE group addressed EAPOL frames in mac80211 anyway due to Linux
> bridging code not doing this,

No, we don't. We have to drop "unicast to somebody else". Group
addressed frames are dropped just fine.

johannes

--=-srbYuINnusWYGVEIPzR6
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2fAHKVg1VMiehFYAQIwjw/+O1M4aK0D0xHVE5FBpVB1n0PM/KvmAlwg
gPMF+p/3IdRSxzgrtPc1ZZXxUcpN1eWe2a4an2W/5duAGE3TqAMseV6IDlhnUyLT
IhGIbfaAaRRRdpZWlamQdV9iZ+SBfZUDgHKAN52SaGbhT9MtvgmkauLhbB7jU96n
zc2+rasQ2C0RRcMeDEnMsY9rCDwVpUMX1K+/5I8iHuvYMItNREd6MQTFWx5njU2k
2RQRJkge7oL+zgY7zqYwwMv+pTlMLc6rLy+nQQqDah8o+7ZQgAC686GAXN9MdK9f
iNc4LCLx0hYKreT0FaWzjDG9baa34V5XTsgc14pOz90TfNldWESioCwJrHFogdG5
QBAsotafwguSpsdVAmRk1kv//j3l7eYGgfSMaUYOn+xNeo6iHhs+4k61kRTESzL9
cnNgJZUfJbux32/xjYIb6n/0YKNUOOg+xiEPSFClNpnhBzSy3NKdGeRz2xSZ3Fp0
fOx82QTs52r3dEueWOy73tcuEr+H1fg38MtKwNhKtQP2X8qyDj0i/qzghZiMXpa5
UTkfyXjdZb3tCEpnG3TyIgqouwUfPfkHmeWolTnQd3ofqcMwvUtIuuhRnxSfJgM1
k9y1m/kaD1KBsxGjoQy8/llOy5Pq3hwXJ7MKnIOBCDoVCgqJOqBzDI4m3uPsTRci
dchplAMwTyo=
=eKKj
-----END PGP SIGNATURE-----

--=-srbYuINnusWYGVEIPzR6--
