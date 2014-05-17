From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40evf: Use
	is_multicast_ether_addr helper
Date: Fri, 16 May 2014 22:59:41 -0700
Message-ID: <1400306381.8175.88.camel@jtkirshe-mobl>
References: <1400227234-13383-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4022118439090786748=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1400227234-13383-1-git-send-email-tklauser@distanz.ch>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4022118439090786748==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Xfu2phONP/Uy7q91xP1Q"


--=-Xfu2phONP/Uy7q91xP1Q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-05-16 at 10:00 +0200, Tobias Klauser wrote:
> Use the is_multicast_ether_addr helper function from
> linux/etherdevice.h
> instead of open coding the multicast address check.
>=20
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Tobias, I have added this to my queue.

--=-Xfu2phONP/Uy7q91xP1Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTdvrNAAoJEOVv75VaS+3O/DMP/2x+3BbxkrGTduWctFIKGbw6
LMWkl9A9UWPskXMqUXnm57PAICpHczEKot/t2Qck+vxZLq8wquNkwQqSR/fkn35m
lxKhH6ukMs4wZRVHF6yx98ts4rg/4zH9qZCnwr9EOdzcr0ePsEHYAWI9sacdB8MR
YNYhhTS8/SntX9Q291IDip7EEEP8CUZqn/BBF80kqb9GqcvJqjMCH7AJF4gzo2LJ
WlNPZckYme191oxyDiwUgtZIRq6cp3UxE+VmQwC3BoiaorNIhRdv8ksD1kgZ/MZG
Ap/SIFvpZuScxMNnQBYwcSDMp2qKXqURvgDdsWnWS/mR/XWDc3+alv6nqHIJ7Rjz
Cbk/PeSzdQcFX+nu4RnFdpJp49yIQ9BEtXWnHCf3qLuhJGSGLhlyiSPdJkhj4dGD
3KubWQbBbRaKs2k0Kq3gG5yTEKXmOmf6GhNdO3uo3hE6ihW//4kyEYkLiShl6G1z
ku+/KQEbEyaYtYtz3nkpyoWGV3TB2D12UcldVewCdan1dRXfo7qkgh6yZ+Jx8TcC
to0SyOursII2/PheB7s+mql8xmg/2OpueDhGmvYThYsZu+WBFfuiQhzddQFlXK74
a0ja9hUo9IIBIFjVS30yFzCZOqpHKmoSiGgoaXsysePySij48KIr+XpZfQdCA7mn
L5cy6DDcK/rpImf1xvzf
=2FJB
-----END PGP SIGNATURE-----

--=-Xfu2phONP/Uy7q91xP1Q--



--===============4022118439090786748==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
--===============4022118439090786748==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4022118439090786748==--
