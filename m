From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: use global pci_vfs_assigned() to
 replace local i40e_vfs_are_assigned()
Date: Tue, 22 Jul 2014 03:28:34 -0700
Message-ID: <1406024914.18280.59.camel@jtkirshe-mobl>
References: <1405993851-24375-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6749350689831692047=="
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	netdev@vger.kernel.org, ethan.kernel@gmail.com
To: Ethan Zhao <ethan.zhao@oracle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405993851-24375-1-git-send-email-ethan.zhao@oracle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============6749350689831692047==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-To50B+pDlOsK7ZpwkSbR"


--=-To50B+pDlOsK7ZpwkSbR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-07-22 at 09:50 +0800, Ethan Zhao wrote:
> There is global funcion pci_vfs_assigned(), so use it instead of
> composing
> local one.
>=20
> Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   31
> +-------------------
>  1 files changed, 1 insertions(+), 30 deletions(-)

Thanks Ethan, I have added your patch to my queue.

--=-To50B+pDlOsK7ZpwkSbR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJTzjzSAAoJEOVv75VaS+3OUhUP/Rkti/SLyuGsGQkG+U6+yo7a
807REHWrxFw9eBQY/XwLXuw+GMRCM33nF2NihmbOHfBpVovnv/47w4k+ROGHGviq
eqONZx0JxjKwgVL96cJR1Jyj15XIUPT0u0H9QMdxkgB1pn/hChlvt8S3GbIRf5VA
i586LCMas2+W5z5Bn9HMOKq6rnLEKJbirkKIAs0yYOMSNkpVOX7RDcB1Ohy23Wxg
IZdREzhx2Zo1Kz3UubjxM7nWYdsR2BMs/0sFrGMXFMvQ9B3okzL48euy8Y58CHHf
jJf0XvllJH5XV7UMYt2frzj/SE3eGhx8gYE/hsLy35pxjM85npmWJY8pwzZABk6J
MnqlHTJppmdr+bCin/jCwENZforF+4d7tHdiCIg9wtWZLPSzvBaUR2926Pm1TMfX
gftXrvHbBhvEYKdQNxJ1hXiTYoH0QGkd6Bb3vI6Dl7/rHpkgpcndg4H0mveeATlT
fYSGtB4F5ux4NaomSlacHsRrwiXYgEGbI+XAFACF39Gjc1ce7oJQ0PRI9JdtipL1
5FYwo7OQVnC8bNAyadpuYEJMjL2QsyE8lmHl+j22Rb0MmIjv90invtbDPzaDr69s
KGc2NlD4jdH8G8xxLr5qBeMf3Fjj/myJXgSw1isB6Q/vWzFUoiZklNKc5cZlzq+X
sNdypguBVfc4UXsC5eUg
=2CEa
-----END PGP SIGNATURE-----

--=-To50B+pDlOsK7ZpwkSbR--



--===============6749350689831692047==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
--===============6749350689831692047==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============6749350689831692047==--
