From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 00/10] Split UFO into v4 and v6 versions.
Date: Wed, 24 Dec 2014 19:11:20 +0100
Message-ID: <1419444680.4705.129.camel@decadent.org.uk>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
	<586203981.237162.1418880532523.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2177754135935601803=="
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevich@gmail.com>,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <586203981.237162.1418880532523.JavaMail.zimbra@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============2177754135935601803==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-n/30AcvMQUBve0z9rAIw"


--=-n/30AcvMQUBve0z9rAIw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-12-18 at 00:28 -0500, Jason Wang wrote:
>=20
> ----- Original Message -----
> > UFO support in the kernel applies to both IPv4 and IPv6 protocols
> > with the same device feature.  However some devices may not be able
> > to support one of the offloads.  For this we split the UFO offload
> > feature into 2 pieces.  NETIF_F_UFO now controlls the IPv4 part and
> > this series introduces NETIF_F_UFO6.
> >=20
> > As a result of this work, we can now re-enable NETIF_F_UFO on
> > virtio_net devices and restore UDP over IPv4 performance for guests.
> > We also continue to support legacy guests that assume that UFO6
> > support included into UFO(4).
> >=20
> > Without this work, migrating a guest to a 3.18 kernel fails.
> >=20
>=20
> This series eliminate the ambiguous NETIF_F_UFO.
>=20
> But VIRTIO_NET_F_{HOST|GUEST}_UFO and VIRTIO_NET_F_HDR_GSO_UDP is still
> ambigious. I know it was used to keep compatibility for legacy guest. But
> what's the future plan? Differentiate UFOv4 and UFOv6 in virtio features =
and
> gso type in vnet header looks sufficient?
[...]

The IPv6 fragmentation ID needs to be added to the vnet header, to do
UFOv6 properly.  If it wasn't for that lack, we wouldn't have to split
the feature flag.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-n/30AcvMQUBve0z9rAIw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVJsBzee/yOyVhhEJAQoDlw//X+2PLB3MKd6HKXCFEHLoESyFwac3Zhrx
Ay3809FE4/U21nHiqtPDyh41KTt4w6eYeLpSE8zYrWMCSD+4GtqYgcmurT8SRlGt
kM+x57LjDmO8PgVCgGkS+VqRg+eW85G0Y71mFRBgkCCYvou20LLPNkK4ri7pmcE6
u6DPb/oRLg9qwP7pscUcodPBVsTIOJa0s9B7lsZW2eRGBdv0ZFL6GG/qrR5PFovu
YPUYSI45wZOkClQIwI++ioDFkYIiKYhNcptBPHWza2zrX595ROEPyctkyyWZnwA3
w78Hw/xcMkTdE04xtgxBpWiXI/XeCLEODrz7KQY1gpjBGkLS3knU+7ZM5zMkOfMF
J78y+2lH2tKeT3wAprQYnw5rghPmMelNr7o7Id2mCtTTeYk4mWwSgWkaEx0AtCZt
YI3wbxNx8fiVTNFxM0T2vNnjUaJLXqF9xjwFzJWJgAtfljOrx83Lqtu43Yg1BZLA
kZhcAKv4dAPVmFrH4ReOsU6PDsZcIQkbV7mAQ93ItY1jxA5g02OzFY41KgmAoem/
Xiv++cMrj6NA2x8vElt2pAMZZsjpeErGY5yTA2oCaSsRA+rZc/dMxqRl0EIpmJ6L
kjVFDWaS3fGLElg5LEto1CVXVsb0E7U4laBBGwcy635O9qYVl0CJf5ume/XLAfRJ
3Fnxw74vMN0=
=+eL8
-----END PGP SIGNATURE-----

--=-n/30AcvMQUBve0z9rAIw--

--===============2177754135935601803==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============2177754135935601803==--
