From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] e1000e: fix the build error when
 PM is disabled
Date: Fri, 14 Mar 2014 01:55:43 -0700
Message-ID: <1394787343.2167.48.camel@jtkirshe-mobl>
References: <1394780233-8066-1-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4561376667088049128=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Kevin Hao <haokexin@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394780233-8066-1-git-send-email-haokexin@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4561376667088049128==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9TlLOsGLgGoWpI5pZN8a"


--=-9TlLOsGLgGoWpI5pZN8a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 14:57 +0800, Kevin Hao wrote:
> The commit 2800209994f8 (e1000e: Refactor PM flows) changed the
> SET_SYSTEM_SLEEP_PM_OPS to open-coded assignment, but forgot to
> protect them with CONFIG_PM_SLEEP. Then cause the following build
> error when PM is disabled:
> drivers/net/ethernet/intel/e1000e/netdev.c:7079:13:
> error: 'e1000e_pm_suspend' undeclared here (not in a function)
>   .suspend =3D e1000e_pm_suspend,
>              ^
> drivers/net/ethernet/intel/e1000e/netdev.c:7080:13:
> error: 'e1000e_pm_resume' undeclared here (not in a function)
>   .resume  =3D e1000e_pm_resume,
>              ^
> drivers/net/ethernet/intel/e1000e/netdev.c:7082:11:
> error: 'e1000e_pm_thaw' undeclared here (not in a function)
>   .thaw  =3D e1000e_pm_thaw,
>            ^
>=20
> Signed-off-by: Kevin Hao <haokexin@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
>  1 file changed, 2 insertions(+)

Thanks Kevin, I will add this to my queue.

--=-9TlLOsGLgGoWpI5pZN8a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTIsQPAAoJEOVv75VaS+3OORcP/2a9crF0ANjX0g5Z8eFd1Ic/
RNxCFe+Y24shVk+EtojADfDIeJmFKv7lKOkKuzKrMqhYIHfnZyKD63ssX+qRVN2N
2ODp3AFgV94nUFi9eJV07nfBFRJOhvXVZLptqjkZbeqXDKUKNVmTJl4/gFH/7Mx8
IXsn2YnbXJBNR/2ol6F3o25QD39zJUeePIcEQxIlxhcrekmq6jfwctW7lSisIGwW
v6KVIwcEGApIV0NSGPacTCGVLSD7Nv3LCgvWtQeVcyWjm1FW89zH9Gomak08Gi9Q
v0caVxt+j/HrHtrXne/MpfcEbZCOC1u2hPln5VwC/CaCjq0AsIodpjkTL+ydU6p9
/tMMfCkLBfZ4YU3v5nbQwtNvs4baHY20SVq9G6ypDMsL0g11H+vcLxg3TDu+9NRd
HY7g+a6gcWAartI+uZd6fYdOis4I0DIhXtfaMAaNSmZrNh73f3YKbpFP1ENIHzWW
ed8+fp76vtc3cRKWQlAydsq9/mWtcZKmWQeLJgHIZWR8tT/pYUj/lQD4U2RTx0mw
jaIQlm0F535r9EEibCfYkGEwMjM3Hera+5HvO7rmRN1IQYKg1QJqGZZ68JYO9m6p
ru2ayYWNeTtKckzuQY+y6OVDBSC2f5Xn99e0vTdlLqJSGfv9ZnRNQ4jK69qk1bmP
kjC44QYhiQBzdifOPlKY
=xKl0
-----END PGP SIGNATURE-----

--=-9TlLOsGLgGoWpI5pZN8a--



--===============4561376667088049128==
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
--===============4561376667088049128==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4561376667088049128==--
