From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: ZD1211RW unaligned accesses...
Date: Fri, 30 Nov 2007 12:33:47 +0100
Message-ID: <1196422427.6058.179.camel@johannes.berg>
References: <20071120.040546.222294375.davem@davemloft.net>
	 <47442BFC.8090008@hotmail.com> <20071124150216.GA28153@gondor.apana.org.au>
	 <20071129214533.GD32730@tuxdriver.com>
	 <20071129234327.GA23769@gondor.apana.org.au>
	 (sfid-20071129_234339_196157_36CABDC6)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VxnZnbr2cjTv3E47Cbie"
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Shaddy Baddah <shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071129234327.GA23769-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> (sfid-20071129_234339_196157_36CABDC6)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-VxnZnbr2cjTv3E47Cbie
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Chances are it does make progress however we may still have the
> general wireless/IP stack alignment issue that we are still discussing.

Yeah, it's still on my list. I'll make a patch to WARN_ON unaligned data
in a packet... although this is a bit complicated. ath5k actually had a
bug with this where they simply ignored the hardware-added padding in
QoS frames initially which would result in "corrupted" data...

johannes

--=-VxnZnbr2cjTv3E47Cbie
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0/1GqVg1VMiehFYAQK+/A/+Il9sZxzucdZFTVbKM5G0oZHwos/UxvGf
wqsNzdC+EeqxmpG2MzbogI8mZD5xXIqJ3d483+2WktOKWOFQTiaBxDbLxx6XlxnO
B3PJyWBr2WmW/eM8PHZehVpBPB2Mx6IhxSLYbe1Ux7VbrjzlOIpbJAK0YmZjrD3C
CbOOAg5wWmpbI0oLs7ySEy2LxWteA9ZdIfDRNy49lwl6dT9ApXJxcOP5JNeFHEtn
Y+OshIWyXqAfRIuH/O3jz6hTLiBgYxE8OAduP00dBKQCWw9hA06HNvDrZcZSwhPE
LSo5KGPljWvAv3MvTCtZQNl28cU/slhFisf9TPA4p8eLVuwss5K26TscStIw3ep2
9zMxLNeDATDMTD1ywqTh82lshGlCJuJhEAVJCYBCJZwJPsQZdK++WvhizHQfnzcG
0vjs2RXMvwVMwEdiyV6cSGGmPSI7ih3W0CptJiEcOODn6g6Q/veJg447q6m70HLl
eND+WEo1STftHRSDmNmce+KV7h6rZkvKUdHnvLHgkjrKOwzxX4ExAT3SHGjaib6k
oCYC00nsHEh88iZFmiFAwKZBCAAyjMxG36EBkDfjCNcrsih/TKzQtKHPs3hQVKUn
Fw8wZyo0wlkjqg5tvPtq6ZtFc7dbaTfIBeyyvLyAI467ei9yHyUwYi11erq35fNQ
zne2AyReIfQ=
=d+S4
-----END PGP SIGNATURE-----

--=-VxnZnbr2cjTv3E47Cbie--
