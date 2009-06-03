From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
 802.15.4 devices
Date: Wed, 03 Jun 2009 11:39:24 +0200
Message-ID: <1244021964.10665.5.camel@johannes.local>
References: <1244021629-18409-1-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-2-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-3-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-f1uVj3P7zhwS81FSTB85"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, davem@davemloft.net,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Sergey Lapin <slapin@ossfans.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49576 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbZFCJj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 05:39:29 -0400
In-Reply-To: <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-f1uVj3P7zhwS81FSTB85
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-03 at 13:33 +0400, Dmitry Eremin-Solenikov wrote:

> +enum {
> +	__IEEE802154_COMMAND_INVALID,
> +
> +	IEEE802154_ASSOCIATE_REQ,
> +	IEEE802154_ASSOCIATE_CONF,
> +	IEEE802154_DISASSOCIATE_REQ,
> +	IEEE802154_DISASSOCIATE_CONF,
> +	IEEE802154_GET_REQ,
> +	IEEE802154_GET_CONF,
> +/* 	IEEE802154_GTS_REQ, */
> +/* 	IEEE802154_GTS_CONF, */
> +	IEEE802154_RESET_REQ,
> +	IEEE802154_RESET_CONF,
> +/* 	IEEE802154_RX_ENABLE_REQ, */
> +/* 	IEEE802154_RX_ENABLE_CONF, */

This is a recipe for disaster. Somebody will come along and uncomment
things. Why this is bad, I leave as an exercise for the reader.

johannes

--=-f1uVj3P7zhwS81FSTB85
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKJkTJAAoJEODzc/N7+QmacIAP/j4pABnzbTeH28988f091okj
X/woSZkYWYMpopmE/TAHXuQrsPDgt3MGzutTnXb2ctVZzLQb+iN5JpRtT2VE45ba
Bz7sHuWLPw1GJZsS5bbETgGoho7NCZj/3fWHrdppgKoOI8qbIdIH3iEnjeiPTR8S
/OIoDzASLfJ/5JunYZCpbfFrBn9lc0tKaus/LISO8r+rPUoL9dBuTzjqGCOuwMek
T3yTEs5eTyIxyUMmDLkYV6BfrGjubGiEPLM/6CAh99PkC/MNLo9WQANi8Kl4mmlo
dXb1Cq/mydhhSGHTdzIZ2UWTCY/BQCCh0lFBrTqvEfYb4NdkhHhTAEW91g0VeY8X
+579VKNr+kCGpej0mSGKsJ127YJIM5ueSixAWLUiuinIcX+QrIFKi2nqdv7eYI2K
7Fmi4/y3jzZiPe2cDGvCzBdwZZ98G1CzzrCQUgOqQ8HZHNQHYrWtL1eY2E9639aG
H/cBAED9qTGyKew+aUbXFcT1+zVd0sGZmTbZoQMz0MiaGa0E4NHHz+ofvDfXJoY+
broEJ3LH/3OcF4Z2WTx+YuNXMJKDZyrpadnrHh/7se8th/8DaHZWb8Y7EyujYI2i
dHTX/DphX201FijyiNFXqfWxVqMAaSFovmpJ3rrE4NlihAGsSmE8GrqVMl3nDMvm
pwdl74AZxvhugdrhM3Nh
=uRcT
-----END PGP SIGNATURE-----

--=-f1uVj3P7zhwS81FSTB85--

