From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v1 0/7] net: extend ethtool link mode bitmaps
 to 48 bits
Date: Mon, 05 Jan 2015 02:30:03 +0000
Message-ID: <1420425003.5686.155.camel@decadent.org.uk>
References: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
	 <1420408540.5686.140.camel@decadent.org.uk>
	 <CAHo-Ooxi8V_58b456vePY9_7ChuBe0jxEVHvGkGvRBpAR744yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vrBFagOxJftVlrwlN+z8"
Cc: David Decotigny <ddecotig@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	Govindaraj
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHo-Ooxi8V_58b456vePY9_7ChuBe0jxEVHvGkGvRBpAR744yA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vrBFagOxJftVlrwlN+z8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-01-05 at 01:34 +0100, Maciej =C5=BBenczykowski wrote:
> >> I can send updates to other drivers, even though it's rather pointless
> >> to update 1G drivers at this point for example. Please let me know,
> >> but I'd prefer to do this in follow-up patches outside this first
> >> patch series.
> > [...]
> >
> > They should be changed to ensure they reject setting any of the high
> > advertising flags, but it's not urgent.
>=20
> if old drivers advertised a get/set_bits function while new drivers
> advertised a get/set_new_bits function,
> you could not updated any old drivers, and simply take care of
> rejecting invalid bits in core, by calling set_new_bits if provided,
> if not, rejecting bad bits and calling set_bits if no bad bits were
> set.

We've never checked that the reserved fields are zero before, and I
think there are still drivers that don't fully validate the existing 32
bits.  So while I think drivers should fully validate the advertising
flags, userland generally can't assume they do.  And therefore I don't
think it's worth adding complexity to the ethtool core that only partly
fixes this.

Ben.

--=20
Ben Hutchings
This sentence contradicts itself - no actually it doesn't.

--=-vrBFagOxJftVlrwlN+z8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVKn3MOe/yOyVhhEJAQrclA/9Ep1AeVxogiycO9th4LvZ4dh5U/oEos3S
QbLOG202zE/zLLD7RGfSvt6y04uuaSgc7sQ95WBZlajqtT+OrSrTu4JAVIBTLeqi
FVZgxO/TvMQJa0VPxqqqnZVOEYjBoqHilGnlEZ3Je1WKYH0neFZa5AfSRSuas+iw
WlP7zTt5xBskf9Zt64uG1Pp32iiaYZgt0iFnNHPyP30zp8xUSu1KetjyAI8zzE6J
DucKccDiD+VLIce5R2ztPQGcB+OrOal/stfON0+Qupq3c2M2oJLauCEaQ9mSu/sD
X16VeRUZBYiM76y3JpU3iXFQE6ntJd7YQ8BmOdZvh+W88vQfj50et9DtX9RN7vl1
b6r5guzNP7rJvS+tSqdFkRjLFUhLSP8lfLzWb4WC3ZdhESlhTtW6Jf7Wwu1h3cby
A4U/lP5Omltxk46tvOJ0J3bam8p9VVSJfDlFZv0jnxZ04pZSx7Lwt8FFZGCxeTMp
CA9a9F52nzZ0waVPh1Mg1q9MEmDW+4Z96LMW8wTRFTFNJuX7JA6llhtvux4k+C1Y
ny5D8w2KsujUwwB1tilmy5dI3F5nIUOxVk/VdBMyInB4eR7yOQwqFTv0dTEpoPBN
uYnGCgvnTRGq/66Nd8c9SX3NVKG7zE99A7cPre82zOD05LzNaiLLsetpWgg3Jfx6
MpCuCV9T+NA=
=nSFZ
-----END PGP SIGNATURE-----

--=-vrBFagOxJftVlrwlN+z8--
