From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] netfilter fixes for net
Date: Thu, 21 Nov 2013 12:45:07 -0500 (EST)
Message-ID: <20131121.124507.111045558003717369.davem@davemloft.net>
References: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 21 Nov 2013 10:05:21 +0100

> The following patchset contains fixes for your net tree, they are:
>=20
> * Remove extra quote from connlimit configuration in Kconfig, from
>   Randy Dunlap.
>=20
> * Fix missing mss option in syn packets sent to the backend in our
>   new synproxy target, from Martin Topholm.
>=20
> * Use window scale announced by client when sending the forged
>   syn to the backend, from Martin Topholm.
>=20
> * Fix IPv6 address comparison in ebtables, from Lu=EDs Fernando
>   Cornachioni Estrozi.
>=20
> * Fix wrong endianess in sequence adjustment which breaks helpers
>   in NAT configurations, from Phil Oester.
>=20
> * Fix the error path handling of nft_compat, from me.
>=20
> * Make sure the global conntrack counter is decremented after the
>   object has been released, also from me.

Pulled, thanks a lot Pablo.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
