From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igbvf: add missing iounmap() on error in
	igbvf_probe()
Date: Mon, 23 Sep 2013 14:11:15 -0700
Message-ID: <1379970675.1906.4.camel@jtkirshe-mobl.jf.intel.com>
References: <CAPgLHd913mcS89QxCc8G5dDPmq5jY1CChdj9gGUPq0RH204gHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1464935318841489570=="
Cc: netdev@vger.kernel.org, kaber@trash.net, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net, yongjun_wei@trendmicro.com.cn,
	john.ronciak@intel.com, gregkh@linuxfoundation.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAPgLHd913mcS89QxCc8G5dDPmq5jY1CChdj9gGUPq0RH204gHw@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============1464935318841489570==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Xx0gRGpfEAQY3GWkNanK"


--=-Xx0gRGpfEAQY3GWkNanK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-09-23 at 21:50 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> Add the missing iounmap() before return from igbvf_probe()
> in the error handling case.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Thanks! I have added the patch to my queue.

--=-Xx0gRGpfEAQY3GWkNanK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSQK5zAAoJEOVv75VaS+3OaiMP/RNFVS8s/fLkj7lyffQCYNfv
DyqYXj+z9aLzISKQmIlL0SZsCyNYq1RGo9/ZGMn8HK0QSkOvDEdgCDAW6wjfj6pg
osStk5BZFYqdoEpEVxs2Xqli0pBiBIzl6BHpgeCMCv7iMpu0dZygEoz3d4aBSyZ7
eMeb7/0NlQb5kftSf1NGSVSkXHUEaGHNThjO9PLgYSa50WtP5PM///78P877fGQx
xHKG/kxLejpSxp0AZkU1o8gRuaKSxtOTRj1AZ3AwtzdprOmRz1w4jXx8iqneemrP
h/RaceGYTHKblx2r7joaLzlH7ih9XL1rZlTHcYKxtppbBtz7DqoD88wFx+HkmH2S
RXWGLyl7wgea3/0ymFrkZx70OBiDr9yCJFHge46VoKyoj1FQTo3hE9GfNka5lwzu
8OUecKjKJhXbUSMBFPvlI5vAfhy6rdqakj12093WsgZlFPAPL8xOi8cA5JJBI1rR
H15eInadz77r/Q7Wibksyt3iW+l4piJ97Jti6XvekQoygDWR9VL79bTVzGWCxLHf
3LM/iAfl1fX+PzbVTFvUxvgDUzgILDSxFQBVe0XA0ZkEN18lEgqtu6rjwQoMOC/q
UBrK7YCInG7O32tMlM757lKBeGvfTqT7/M+tE3/9M+JgTGz+H/Vy5snPERGgtjUG
sFQ3mL+C80VyTGWj/j7K
=1G2H
-----END PGP SIGNATURE-----

--=-Xx0gRGpfEAQY3GWkNanK--



--===============1464935318841489570==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60133471&iu=/4140/ostg.clktrk
--===============1464935318841489570==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1464935318841489570==--
