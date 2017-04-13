From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v3 2/3] VSOCK: Add vsockmon device
Date: Thu, 13 Apr 2017 16:02:13 +0100
Message-ID: <20170413150213.GH13387@stefanha-x1.localdomain>
References: <20170412160825.21037-1-stefanha@redhat.com>
 <20170412160825.21037-3-stefanha@redhat.com>
 <20170412193827-mutt-send-email-mst@kernel.org>
 <20170412.130510.1661492983569723913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="0XhtP95kHFp3KGBe"
Cc: mst@redhat.com, netdev@vger.kernel.org, zyjzyj2000@gmail.com,
        ggarcia@abra.uab.cat, jhansen@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55036 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754004AbdDMPCS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 11:02:18 -0400
Content-Disposition: inline
In-Reply-To: <20170412.130510.1661492983569723913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0XhtP95kHFp3KGBe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 12, 2017 at 01:05:10PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 12 Apr 2017 19:43:20 +0300
>=20
> > On Wed, Apr 12, 2017 at 05:08:24PM +0100, Stefan Hajnoczi wrote:
> >> +struct af_vsockmon_hdr {
> >> +	__le64 src_cid;
> >> +	__le64 dst_cid;
> >> +	__le32 src_port;
> >> +	__le32 dst_port;
> >> +	__le16 op;			/* enum af_vsockmon_op */
> >> +	__le16 transport;		/* enum af_vsockmon_transport */
> >> +	__le16 len;			/* Transport header length */
> >> +} __attribute__((packed));
> >=20
> > I'd add a 2 byte padding here and then you do not need to pack it.
>=20
> Indeed, use of the packed attribute is strongly discouraged.

Thanks will fix.

Stefan

--0XhtP95kHFp3KGBe
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJY75L1AAoJEJykq7OBq3PI9KwH/0C6kLlZ65DEFCNyba4bL234
eDJQzSE1FzWQEeO6WvXbqZbNfMvP+bR5qftWkkxdqI5u8QBBQfnz7rNdYnCvmhYh
l+mfp3QXb3tanyk481nOCPjWFhaykvmGSKIJ+Pxc8888pBq3eY8QGPJEQ00BHfBn
Qyr58b7G91S1ngkk1T74VggC2oYnDWZgM+TGvizx0zjXuH++8He2xZczoIapTG4o
b/+vurQvEYzrX/Zi4p2EFdzvJzmZOXJCzenLceoBvWCI2qIGRDKTiGAGz0dRDEdU
/AN+Dmb0jkpkTJSwHWNfBWt0eI3LL8uNzeSoMrF6jGjC9D11Idvp+Vcyxc4ZtxM=
=iaqY
-----END PGP SIGNATURE-----

--0XhtP95kHFp3KGBe--
