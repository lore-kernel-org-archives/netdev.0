From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] netfilter: Fix br_nf_pre_routing() in conjunction with
 bridge-nf-call-ip(6)tables=0
Date: Tue, 03 Jan 2012 21:29:01 +0100
Message-ID: <4F03650D.8050200@nod.at>
References: <4F025A07.2000304@nod.at> <1325597164-13459-1-git-send-email-richard@nod.at> <1325597164-13459-2-git-send-email-richard@nod.at> <20120103081521.2fec3a29@nehalam.linuxnetplumber.net> <4F033E11.5060707@nod.at> <4F0361D7.3000602@pandora.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6E73FD4239D9CA1170A15979"
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F0361D7.3000602@pandora.be>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6E73FD4239D9CA1170A15979
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 03.01.2012 21:15, schrieb Bart De Schuymer:
> The documentation is probably not explicit enough, but I would keep the=

> behavior as it is now. Setting bridge-nf-call-iptables to 0 makes
> iptables behave as if bridge-netfilter was not enabled at compilation.
> Anyway, your patch is almost certainly flawed since the fact that
> skb->nf_bridge can be NULL is used as part of the logic in
> br_netfilter.c: it indicates that bridge-nf-call-iptables was 0 when th=
e
> packet was first processed by bridge-netfilter and should therefore not=

> be given to iptables in any other netfilter hook.

Thanks for the explanation!

Wouldn't it make sense to check for bridge-nf-call-iptables in xt_physdev=
?
So that the user gets warned that his iptables rule will never match...

Thanks,
//richard



--------------enig6E73FD4239D9CA1170A15979
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPA2UNAAoJEN9758yqZn9esRYIAIk5GxS5s1dkDZwOKdvuUUCZ
3AQddHjP1yAMsluheZCXjgZNJ6cItl0T+y+0iwKZow0oNHkjp8czgCfyF6W97xSm
4fAKYDwAMfwiJsqunvOowVBo1+xFTVLBsOo9fAf/6zsRbKJrth2oNG3ijRa5iZuf
mwbs1j3AdCWGUksF7vKVDemkO3eXFX8tdDbqfFKGfjdjPXRMo0AGzMkkNKZFfhJ8
v1llsdO1y5+Z+G8fK3BOyHdUzaCUHqYtLJ4GEznF3IqyFXcSir51dhwkfnidAnUP
rtKYds5Rd7WsbAnSseb0eJWMLHz4/XwqEdOJBpAG+TzLIZA48B8kST6DZdFoQCc=
=LJRl
-----END PGP SIGNATURE-----

--------------enig6E73FD4239D9CA1170A15979--
