From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] networking: fm10k: Fix build failure
Date: Thu, 09 Oct 2014 22:22:32 -0700
Message-ID: <1412918552.2427.12.camel@jtkirshe-mobl>
References: <1412918346-24763-1-git-send-email-bobby.prani@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6553475377393017806=="
Cc: Don, "open list:INTEL ETHERNET DR..." <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	open list <linux-kernel@vger.kernel.org>,
	Ronciak <john.ronciak@intel.com>, "open
	list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	Linux NICS <linux.nics@intel.com>, John
To: Pranith Kumar <bobby.prani@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1412918346-24763-1-git-send-email-bobby.prani@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============6553475377393017806==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-F4jrQqh7Xwoq2M5+sLrV"


--=-F4jrQqh7Xwoq2M5+sLrV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-10 at 01:19 -0400, Pranith Kumar wrote:
> The latest linus git tip (3.18-rc1) fails with the following build failur=
e. Fix
> this by making PTP support explicit for fm10k driver.
>=20
> rivers/built-in.o: In function `fm10k_ptp_register':
> (.text+0x12e760): undefined reference to `ptp_clock_registER'
> drivers/built-in.o: In function `fm10k_ptp_unregister':
> (.text+0x12e7dc): undefined reference to `ptp_clock_unregister'
> Makefile:930: recipe for target 'vmlinux' failed
>=20
> Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Dave- go ahead and pull this in directly, no need for me to put this
through our internal process.

> ---
>  drivers/net/ethernet/intel/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/in=
tel/Kconfig
> index 6a6d5ee..6919adb 100644
> --- a/drivers/net/ethernet/intel/Kconfig
> +++ b/drivers/net/ethernet/intel/Kconfig
> @@ -304,6 +304,7 @@ config FM10K
>  	tristate "Intel(R) FM10000 Ethernet Switch Host Interface Support"
>  	default n
>  	depends on PCI_MSI
> +	select PTP_1588_CLOCK
>  	---help---
>  	  This driver supports Intel(R) FM10000 Ethernet Switch Host
>  	  Interface.  For more information on how to identify your adapter,



--=-F4jrQqh7Xwoq2M5+sLrV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUN20YAAoJEOVv75VaS+3OJNEP/1hB1hpgV5W1RVXaZjeij+If
iXHUVLSy1yfdI7pyl2vfRhGW115dMAOeMd0i6BryPE85tpT5RpfROLSSKrq9IgJT
JxURqHF9pRn29dSDMf5chGieZodEc9MIglCYp6cqyKiBEK+8Jry7RAr9rgUZj8s4
emtmoKWGfn3PcHqszRQYwhLwhq4LzR+V/Retcor5pnjEGWT2X9NFlSXSpveWaQcD
VX4UVJSkhiXR5u6GoDqcgSOyLhOlgScNEMw28IABPgO3OsbgaE4EOiGig44c6oqa
M+6ObBjtwB6VQUqopLAgxKelXiK2UuINny5Yyv36WboxQo4H75wu5wv+GM/VE4b1
q+hMlk8Ada1s0KL6J54wHq9XXDidc/XYvLOBCjEXj90U710wPUIBm5aAc2HUXR9M
wKf4iWX40cr7TFf76g8w48FwU9agoRfdaAauidIXTiIdNFGSl88Q7UgJXlaNnRbP
s6eaIA08s83pFp/kVjtmAntopvQRkHTc+uP40xbz2JOQhBoC8ylque+HuI1QgAJI
IELTI6tkVq6+nY8AburKXA0ADhzlJwEg58OvrLZUJhg++kU7HL2OW7gGqor2Rkj7
uVv9ikexGKetL5OGpLaV+wj8+pleepxwzcqemxAvoIOwEUC3xOv+jkZH+79vZOKc
iqHUB4M66OJSpRYf80AZ
=Jrb0
-----END PGP SIGNATURE-----

--=-F4jrQqh7Xwoq2M5+sLrV--



--===============6553475377393017806==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Meet PCI DSS 3.0 Compliance Requirements with EventLog Analyzer
Achieve PCI DSS 3.0 Compliant Status with Out-of-the-box PCI DSS Reports
Are you Audit-Ready for PCI DSS 3.0 Compliance? Download White paper
Comply to PCI DSS 3.0 Requirement 10 and 11.5 with EventLog Analyzer
http://pubads.g.doubleclick.net/gampad/clk?id=154622311&iu=/4140/ostg.clktrk
--===============6553475377393017806==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============6553475377393017806==--
