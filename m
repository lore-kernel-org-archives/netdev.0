From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v1] e1000e: honor pause autoneg flag
Date: Wed, 16 Jul 2014 02:23:46 -0700
Message-ID: <1405502626.18280.1.camel@jtkirshe-mobl>
References: <cover.1405462125.git.decot@googlers.com>
	<98ea4a6a8e42ffa454d5d42749262e8df02c0167.1405462125.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3687498786465622884=="
Cc: e1000-devel@lists.sourceforge.net, Linux NICS <linux.nics@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@googlers.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <98ea4a6a8e42ffa454d5d42749262e8df02c0167.1405462125.git.decot@googlers.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3687498786465622884==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-D/+geDXLYimwsoKCuTYu"


--=-D/+geDXLYimwsoKCuTYu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-07-15 at 15:09 -0700, David Decotigny wrote:
> Before:
>   ifup eth0
>   ethtool -A eth0 autoneg off rx on
>   ethtool -a eth0  # rx on, as expected
>   ifconfig eth0 up
>   sleep 5
>   ethtool -a eth0  # rx off, not expected
>=20
> After:
>   rx on with iface up, as expected
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
>  drivers/net/ethernet/intel/e1000e/mac.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Thanks David, I will add your patch to my queue.

>=20
> diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethern=
et/intel/e1000e/mac.c
> index 8c386f3a..ef014ae 100644
> --- a/drivers/net/ethernet/intel/e1000e/mac.c
> +++ b/drivers/net/ethernet/intel/e1000e/mac.c
> @@ -1048,7 +1048,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw =
*hw)
>  	 * has completed, and if so, how the PHY and link partner has
>  	 * flow control configured.
>  	 */
> -	if ((hw->phy.media_type =3D=3D e1000_media_type_copper) && mac->autoneg=
) {
> +	if ((hw->phy.media_type =3D=3D e1000_media_type_copper) && mac->autoneg=
 &&
> +	    hw->adapter->fc_autoneg) {
>  		/* Read the MII Status Register and check to see if AutoNeg
>  		 * has completed.  We read this twice because this reg has
>  		 * some "sticky" (latched) bits.
> @@ -1191,7 +1192,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw =
*hw)
>  	 * flow control configured.
>  	 */
>  	if ((hw->phy.media_type =3D=3D e1000_media_type_internal_serdes) &&
> -	    mac->autoneg) {
> +	    mac->autoneg && hw->adapter->fc_autoneg) {
>  		/* Read the PCS_LSTS and check to see if AutoNeg
>  		 * has completed.
>  		 */



--=-D/+geDXLYimwsoKCuTYu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJTxkSiAAoJEOVv75VaS+3OFN8QAIRSYd9DNV7+4r4tniYSQMmx
UYtlrP0LaNSH1JECV6dunTyNmEViJDIt1fl4UGyOVcXuPvKpNOse4zeFgfisEaRr
F58VAiaKEQ1HZJWGOrtlhQWWKAv7jXDP1yaOeK+17qxM+u2G9ZmGQuFgnVUcIfCF
qnTsvRmfDIPHBrsv5TYYyMdnOFaaSshFyYiSaZZN09heZNbl1cbPA1o3GHCNuHds
yln9PuVXpxQttxr0Z140gqJpmLiDUY0sPHuC4BuPl7/wB8ldiVwme+27wUk+gigH
0GgsYCnSN42XinYVUwCzwpaUzthjpro5VaGSO5slzl0OsHiFVzBgYuVaLDtbD0Aw
5R0/XRHs7Qel/FXbuVgXedIRJH65cEmyXw38ulQeV8Kh7E9cjsuW1cNUy4SJE0fS
Oogzl/95xSbCssh9A7bw/JLx+ard2LEtsSkY6S+XqUgF1pnigJADHo8XoPcbCt+t
vm4WbzikFk+f/7CUcFElpUVu8fydji7BISajbI+bTl4fubJuqlDfdhxCRb+D242z
ILOr4kaBNYM12gAbzKLPPGzyRtZaYfxfwR/8TVxnHUJzfzMVHTN+Pv0eN0QFwTyb
G+vfvuyBrszAIZphjS8rCGZazgRRbg9ADsagsFf3/Mv/c3lfH+dO7ebhOGhDGC1Y
6xR9EzCvo+WZtGOQB5id
=Ykx+
-----END PGP SIGNATURE-----

--=-D/+geDXLYimwsoKCuTYu--



--===============3687498786465622884==
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
--===============3687498786465622884==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3687498786465622884==--
