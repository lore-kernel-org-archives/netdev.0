From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the drop-experimental tree with the
 net-next tree
Date: Fri, 2 Nov 2012 15:55:14 +1100
Message-ID: <20121102155514.939282b4682c521f07e7943c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__2_Nov_2012_15_55_14_+1100_ZesQDe77+ORwRkej"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Kees Cook <keescook@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:44864 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab2KBEzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 00:55:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__2_Nov_2012_15_55_14_+1100_ZesQDe77+ORwRkej
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kees,

Today's linux-next merge of the drop-experimental tree got a conflict in
drivers/net/ethernet/intel/Kconfig between commit a24006ed1261 ("ptp:
Enable clock drivers along with associated net/PHY drivers") from the
net-next tree and commit 70c5056f413d ("drivers/net/ethernet/intel:
remove depends on CONFIG_EXPERIMENTAL") from the drop-experimental tree.

The former removed some code that was changed by the latter, so I did
that and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__2_Nov_2012_15_55_14_+1100_ZesQDe77+ORwRkej
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQk1IyAAoJEECxmPOUX5FEChUP/1tZ0iPHeX3wRJGmLtqZajjR
gGiCRv0lEKfPQwXhlYH9+vxS04Vmn9Q+YLwKsrrmhSllEgmUCFrK002ea9q3Surd
ZwTvlkfXiySokO29t4sOdfG/iOo6+DjEWRB0CggJX5ffqeZz0WJJz/OkrExFiMPg
jy7VK3bJerdOZ6eURGwJBixg7duYV1YguajCijQTDKOlYONS12qtse446q8lael5
9h6VRu/4GSUvnaFu8P4n4G85Z4ZTbwydqNCci7cXLuX5lygwRJC9c4OxHcBc2CFA
4SLS4/H4GskTmZrfnd7fmpqlnreH0LsQ6CpidT9RzJqpbVJYFMeidnmzyh9SvrFZ
wzPfF7t4YgYuqFVyw9mDbTsCv51PD9cWMa+c7pMg/7h8XC6WjEjkTzbHJM0GXk7Z
RVjaxfMdsSXJj4Tz5ZX1fQNmlNo4JZrUT+VXmclDQisBC1zahokx0F5PlsWDK/Q7
EdMyyxV0jELsQJFbLLhnhUTa2AfyA4a+D3lwNVTt1gA/6pw3JrhRmNbjr4OzGxw1
Vh5/peCRR41Kj+7fi+7GCIQPAQDlkqzptiXJi47ShizCgEBYeu4xC2RB2CqmPz0/
ST3CtTCGbtFhgOA1QeVVlp1gUwTHZ0Tm/4j8WnrKdf4CNySigVzqzqd64ijf1SvJ
UEKV3zli/rbe7AiF2e7d
=eh0J
-----END PGP SIGNATURE-----

--Signature=_Fri__2_Nov_2012_15_55_14_+1100_ZesQDe77+ORwRkej--
