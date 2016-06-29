From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Question on i40e PCIe relaxed ordering (RO)
Date: Wed, 29 Jun 2016 13:32:42 -0700
Message-ID: <1467232362.3733.23.camel@intel.com>
References: <57742A27.5040207@oracle.com> <1467231519.3404.11.camel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1902253387822772036=="
Cc: netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	intel-wired-lan@lists.osuosl.org
To: Greg <gvrose8192@gmail.com>, tndave <tushar.n.dave@oracle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1467231519.3404.11.camel@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============1902253387822772036==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ibdKTy4uAeLSVjY5a116"


--=-ibdKTy4uAeLSVjY5a116
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-06-29 at 13:18 -0700, Greg wrote:
> On Wed, 2016-06-29 at 13:05 -0700, tndave wrote:
> > Hi,
> >=C2=A0
> > Running iperf tcp test on 2 sparc systems with i40e connected back to
> > back, I see huge number of 'port.rx_dropped' (on iperf server). Based
> on
> > past experience with ixgbe, this could very well because of PCIe RO
> > (relaxed ordering) not enabled.
> >=C2=A0
> > I am trying to confirm RO is enabled. i40e datasheet mentioned RO
> > settings in 3 different sections:
> >=C2=A0
> > 1. section 10.2.2.2.38 PCIe Global Config 2 - GLPCI_CNF2 register
> > contains global status fields of PCIe configuration. The bit 0 of the
> > register is "RO_DIS". If this bit is set to 1 RO is disabled.
> >=C2=A0
> > RO_DIS in my setup is 0 imply RO is not disabled.
> >=C2=A0
> > 2. section 12.3.5.5 Device Control Register (0xA8; RW) has bit 4
> > that enable/disable RO. This is pcie cap register.
> >=C2=A0
> > In my i40e pcie config space value at offset 0xA8 is "2110". i.e 4th
> bit
> > set to 1 imply RO is enabled.
> >=C2=A0
> > 3. section 3.1.2.7.2 mentions some relaxed ordering rules
> > e.g. "The GLLAN_RCTL.RXDESCRDROEN bit (loaded from NVM) enables relaxed
> > ordering for Rx descriptor reads"
> >=C2=A0
> > However, GLLAN_RCTL register definition has not bit like RXDESCRDROEN.
> > Same goes for GLLAN_TCTL.TXDESCRDROEN.
> >=C2=A0
> > Am I missing anything? please advise.
>=20
> I would try posting this question to the e1000 developer list over at
> Source Forge.=C2=A0 The Intel customer support folks used to monitor that
> list closely when I was there, hopefully they still are.

We are supposed to be monitoring both lists, but just in case I have added
e1000-devel list...
--=-ibdKTy4uAeLSVjY5a116
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXdDBrAAoJEOVv75VaS+3OwJkQAKQKZv9QiPk3wDYgMRxAY0eS
ebyiiG0l709UgM3c8a5twZUwpMFoHlUI7kWwhnQfISu0EFhaxNI+VyDxiEnJHVKc
Ey8QNzHc1oi+/FmLy+KYA4+xhWPaffaoVoFkkrgH4TtcjHOrL6jl9g8la66ivwbJ
XIkY3SLiBt21oeg/5Q5WmzMrOduyxaQ8NpkibamNknU79EKUReMyzwmbyAVTn8Bb
y2jOhP7Ubq27jsxFx6j8f6Sy7rlgbmy5S+sGxZmSyikrWhwMWoXy51e9pAS4qMYq
4hKBXmaRXyWD2tCWPxqom/cV/UwOlq7IC1IcrppVYWO9iiP0si7B8ZtFs5I26Jof
9oAxloQSNUgEudukqGklVWhCXrGVgz3h+R/jH5NVsE1Pbud3qZvQtYtXaks4FKuE
kPv7bDXiHXg15sNQxfB0svG/oxHejBtM/pxEZj3ciMxQzBVfh/3t/2yV8p+JFGV5
F3CRWpS4EPjvLMFsBdGHWLwhsOv51y0uDHs5CBPaD2OEI8gZ4IUWQkQ5z+8oGsJ1
Y6FsaLT86guRHUuxC5Z4l4U7G8gIk/tZtjPvepByyKSCx0yN3GQWL4I8AFnmBRWB
W6PbDZgMuOnA+xCqQFZIb5tUKJGx28+L0ktmOHJBAbZJd0ZRU+DIDJV9AgaHFTE9
2grZap5BuK9+KyzI+Rek
=AvI9
-----END PGP SIGNATURE-----

--=-ibdKTy4uAeLSVjY5a116--



--===============1902253387822772036==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Attend Shape: An AT&T Tech Expo July 15-16. Meet us at AT&T Park in San
Francisco, CA to explore cutting-edge tech and listen to tech luminaries
present their vision of the future. This family event has something for
everyone, including kids. Get more information and register today.
http://sdm.link/attshape
--===============1902253387822772036==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1902253387822772036==--
