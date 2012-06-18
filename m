From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2 net-next] ixgbe: remove xmit length
	check
Date: Mon, 18 Jun 2012 13:39:25 -0700
Message-ID: <1340051965.1995.33.camel@jtkirshe-mobl>
References: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
	<20120618115558.1ef26a48@nehalam.linuxnetplumber.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3059250732497903764=="
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120618115558.1ef26a48@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3059250732497903764==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FV+RtSXyU4ENxs7JBXPd"


--=-FV+RtSXyU4ENxs7JBXPd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-06-18 at 11:55 -0700, Stephen Hemminger wrote:
> The check here is bogus. Since len is unsigned, it can never
> be negative. And it would be a bug in network stack to ever
> send a zero length packet to device.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>=20

Thanks, I have added this patch as well to my queue.

--=-FV+RtSXyU4ENxs7JBXPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP35H9AAoJEOVv75VaS+3O+tUP/jcXbbDVQWVq9+mv35pICtvh
yKa1FIJnnYrvKibN5juGLvEpkp72EjQoDnqZZQAnkrSPjYuPKyCuGvU/jsATdleL
3vDo7MMgF4Vb1lhMhPk8zSYa6/+IKu2pY4Ul6zIG8qmPIGSCHj1YW8xZDQVghgXm
nN/Fmda7ywq9s5M+eQc6lq7MfgS+rLKGDHmqPIfdhIZQkgdF2svRJbdhIuJkPsV5
HV4Y0OzbRQ+lEyS2X2ECz0mu6/Oes1PSszT11XrJlp1hkkQWF4OTPFBmDQrvka0U
5z8lWw61TMpw1VPOmdS2C6B+kYeJHH5jq8QpbcG0EXK7R4BrQpOunNeMCh16mCMW
AV0bfLo+fwwDKgOcPTBHb34RXrfIZ9jHYLwiyvX9wlzv2xIZZZE1QYN5HqDhvZYu
NkBRXupWmukpmKRMY2HOKoGn77yxq82+T4w3TJ/kRZPHTtfltyqjYSfmZ3N2TK4q
CQXIYQHKczjWIovZpb9tTbG0+5MesQm+DJms0Rg0bfHK8heAKgU8x3ixJzdQ3KT7
H7vweXZGL1Zllg3QPlWBRowspTaSxuK0OWNcu4u9otXmCxfBxEC6adnrHiOhNDG8
XasVzVQmF77v0Nsro5+daMhrrn6/Qza7rjFg7zqhxp/rGa0OTnXvENCrwCdjrz71
ciYpkum+9NYKlUnMjnsc
=OC8k
-----END PGP SIGNATURE-----

--=-FV+RtSXyU4ENxs7JBXPd--



--===============3059250732497903764==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
--===============3059250732497903764==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3059250732497903764==--
