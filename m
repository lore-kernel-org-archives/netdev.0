From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#709616: floods the network with pause packets
Date: Sun, 26 May 2013 17:10:45 +0100
Message-ID: <1369584645.3469.343.camel@deadeye.wl.decadent.org.uk>
References: <20130524124059.12781.51344.reportbug@wencory.loria.fr>
	<20130524160727.GM4752@decadent.org.uk> <51A07081.5010104@debian.org>
	<1369533273.3469.301.camel@deadeye.wl.decadent.org.uk>
	<51A1CFB7.1080808@debian.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8861619019505139622=="
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	709616@bugs.debian.org
To: =?ISO-8859-1?Q?St=E9phane?= Glondu <glondu@debian.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51A1CFB7.1080808@debian.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============8861619019505139622==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iBCklk6nIwlzz6m2zF1Y"


--=-iBCklk6nIwlzz6m2zF1Y
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-05-26 at 11:02 +0200, St=C3=A9phane Glondu wrote:
> Le 26/05/2013 03:54, Ben Hutchings a =C3=A9crit :
> > I forgot, e1000e still doesn't report autoneg state completely through
> > ethtool.  How about 'mii-tool -v eth0'?
>=20
> # mii-tool -v eth0
> SIOCGMIIREG on eth0 failed: Input/output error
> SIOCGMIIREG on eth0 failed: Input/output error
> eth0: negotiated 100baseTx-FD flow-control, link ok
>   product info: vendor 00:55:00, model 9 rev 0
>   basic mode:   autonegotiation enabled
>   basic status: autonegotiation complete, link ok
>   capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT=
-HD
>   advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-cont=
rol
>   link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
> 10baseT-HD flow-control

OK, so the switch is indeed defective: it says it can handle pause
frames, but it can't.

Could you check whether the switch is also sending pause frames back to
the port that's generating them?

> I am not sure about who to put in CC of this mail; I've just put the
> Debian bug.

You replied-to-all, which is correct.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-iBCklk6nIwlzz6m2zF1Y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUaI0Bee/yOyVhhEJAQotdQ/8CkqaMV3SpC14Pf4KJfsF8slwLTzbdokK
SWQpGm4b1NuUio3eBtpOndnFxY7lqdDgPf0y9ibX4dNn537fiFT2wjWQLQtJ9EIU
/audmH5KJTeicZ8hvnh7lj0cehiEoCt6e3ywzAFixBUcz4pHDt14nN8nUkb4KkY5
aWFSKLAdGYXXWnJXMlFrjIXHeCyF1NtzH+x5/8wplQduARqLXRvv96XOWyKOHtz5
jbgyoOcfjmibjETaia//tjvqUsCLA8jMli9iQ5fqP2BAVccBe9t1S7BKhHlUwpzA
exAVhVrg3/n8Jwo5A7da+dzb9T/wv3bhQGRnBPHOnj9ffGQvNen3+88Gbpe1xERf
MK69LhEIM3bKwmTyXjepKaMzHaQEpi2X7q83EqSpX8wGnT93Tk4h/OVcRaCLG30k
U5ZUjWF5mjaZl1IuJM9FsTuW7ejAOD4eb6ldSsAZlSA1H6WE6+jqn7w4UfqgLom2
hG68nmET9nAvpI84iZhJob5i37QOh1+93tudxMN4+YXiHDgDwSDOIb9MIdtibU/g
ZMO1c12EvKk0d/wDN0bQZ/VPsDkIeVzv61WC6ES5PnpstorTm88lznfA2Lahturo
K2IemMgaMRDAObCyvRpWPH/RgK6uanZdyG/OZuXqwSIS4/EwdDm/uoRVdZ9wrFD3
bf77jglAyRs=
=4pyC
-----END PGP SIGNATURE-----

--=-iBCklk6nIwlzz6m2zF1Y--


--===============8861619019505139622==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
--===============8861619019505139622==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============8861619019505139622==--
