From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 08/10] igb: fix race conditions
 on queuing skb for HW time stamp
Date: Fri, 14 Mar 2014 16:18:30 -0700
Message-ID: <1394839110.2167.94.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	<1394818481-7652-9-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2467093681712783362=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-9-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============2467093681712783362==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9vFDLvYmuIEuaSWtOXjk"


--=-9vFDLvYmuIEuaSWtOXjk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> igb has a single set of TX time stamping resources per NIC.
> Use a simple bit lock to avoid race conditions and leaking skbs
> when multiple TX rings try to claim time stamping.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/igb/igb.h      | 3 ++-
>  drivers/net/ethernet/intel/igb/igb_main.c | 3 ++-
>  drivers/net/ethernet/intel/igb/igb_ptp.c  | 3 +++
>  3 files changed, 7 insertions(+), 2 deletions(-)

Thanks Jakub, I will add this patch to my queue.

--=-9vFDLvYmuIEuaSWtOXjk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI45GAAoJEOVv75VaS+3OA/sP/Rc6ZlaSGkcL6lNaA3c0oFUw
S2tWvGiW7T0ncKCmwPSEzVuNu1ndcStwZdNUhf/k3BWGXXM/hpuYmPaIbayrRJE/
/AbAor1ozv5Q2n370GSm+zabnzBnrwQXdm0iWlQJFt0SXEv1mOxJTTXRB3mhH/yH
kfjtIsd4yAxZQ/pnN2bNLhFaKHlzIRpBEqQK4Fcj5M8jxWmZQZrAT7mISZJGg/h1
YJ39xtpuoQNuBRhpwd4sbl9MHIMw1c23gRtgyc1M6Hm/O1xMGgyrIWzBa0SZWcVN
DOsHZ/6c+8LiXLv/VD8aoZF3Al8rFioLUNL02YdJt337GXQIW9GsZvOkWMTOTSuy
KYah6cWb2SG4gT03dtIvbXw3DVkfnpTEBE6NAeg0XixdaljXmz94LvfUElFyQMi+
c3idlbGKY1PgPfGaj2oUjtxHaJJx486vvlEx//dfKEMI0/H7s7WRUNFoiGbwI1nV
y3acnKrptKNGtMYp5aT9iAOUWDe3BNqe/rwPh3eTsW+r+DwJetsvYhrjnaUDMKiR
xzpgIEL6Iey5PJNjyb7PMuN8bBLQGK8jCrEkFGWVPMoDB7OMJhzO2md909FpVzGH
GXtchEA3le8QK8UDxmWeFBtlGd93DkHHDNJQ21iDQMVbq8eyca3bkUMiqM24ovr5
h9f48uZpqhh3HmmB7IWn
=FTcU
-----END PGP SIGNATURE-----

--=-9vFDLvYmuIEuaSWtOXjk--



--===============2467093681712783362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
--===============2467093681712783362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2467093681712783362==--
