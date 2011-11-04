From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] bonding: comparing a u8 with -1 is always false
Date: Fri, 4 Nov 2011 23:53:51 +0300
Message-ID: <20111104205351.GQ4682@mwanda>
References: <20111104182138.GB5796@elgon.mountain>
 <10444.1320436921@death>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E50aLcSU4JxQSj/B"
Cc: Weiping Pan <wpan@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:48808 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab1KDVDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:03:32 -0400
Content-Disposition: inline
In-Reply-To: <10444.1320436921@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--E50aLcSU4JxQSj/B
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 04, 2011 at 01:02:01PM -0700, Jay Vosburgh wrote:
>=20
> 	Since you #define SPEED_UNKNOWN to -1 (below), how does this
> actually change anything?  Did you mean 0xffff (because struct
> ethtool_cmd's speed is a u16)?
>=20

Sorry I could have explained this better in the changelog.  The
slave->speed is stored in a u32 and the -1 works fine as is.
Obviously, as you point out the define doesn't change anything.  I
just changed it so it would look symetric with DUPLEX_UNKNOWN.

But I think you missed that I defined #define DUPLEX_UNKNOWN 0xff.
Before it we used a -1 for both and that didn't work.

I can resend this with a note about the SPEED_UNKNOWN cleanup if
you'd like.  I'll do that tomorrow or Sunday.

regards,
dan carpenter


--E50aLcSU4JxQSj/B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOtFDfAAoJEOnZkXI/YHqRmPYP/35o3YOc3OojI1Cc+VirkM6o
RCfJzvGPdD0CqcUmvh9DzdOReITHCsn1GsgM65Y84bytThbnmyCuJzAVO87nYvIR
w5RqUhDfnnzWk86FSbZX5J7oAgriRWBIRX8piNNHOJwulNKFOKCBMPyWjzBdJ5Y2
+MV8JXfwyMdpQOVvqO4QaqaspH61C2T0E3aIHTjJWwfZqWReVy4DksQF0E5RpmXi
3zn/DxTV+j1l2RZv00kWpsG3rqwNAfxSSHSnqiqW3A2bINPMrHEMsDFiNlqne1hN
MG6b1Sre13xQIii8304JeSHK+1ICi/oH2ZJW7BVEB+/dV8FsdQoJ53pojO62Ayzq
JutTf1PJeLK0WXnSFpC7p1/wvAjKeSE7Os31a+oAyJZv08Dh95A3F3uDULHZ7a6e
EEWy29n5XioXi6CppXtjAtAijq1n+8qURwCmr5qYw8kld6aLFioo/jkO9rIFiyC3
95/11UhuBqgBO4QhVlx6WNDGPmHtfJfftp3kSm6eLt5ZCs62q1WHOKyquy5fo4oi
+mIyakbhsuy1EXCueVNJu7D5ibFVVfkCuuNUkcXyVGUC2nvlxGYe2+tRtJJpdRfP
39hL/yOn6K+hzVafKAsvCRrna865lmFP0ldKAIJ5plGL/o/8ilfHvJ2twKVRELOX
okaNeMMpkNweAipNUblr
=BjYY
-----END PGP SIGNATURE-----

--E50aLcSU4JxQSj/B--
