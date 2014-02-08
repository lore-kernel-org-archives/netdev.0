From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 12/13] net: Include appropriate header file in
 netfilter/nft_lookup.c
Date: Sat, 8 Feb 2014 12:14:54 -0800
Message-ID: <20140208201454.GL20885@leaf>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
 <401aceca1fc3f95097624fe8433635491b39248d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <401aceca1fc3f95097624fe8433635491b39248d.1391888654.git.rashika.kheria@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 09, 2014 at 01:39:20AM +0530, Rashika Kheria wrote:
> Include appropriate header file net/netfilter/nf_tables_core.h in
> net/netfilter/nft_lookup.c because it has prototype declaration of
> functions defined in net/netfilter/nft_lookup.c.
>=20
> This eliminates the following warning in net/netfilter/nft_lookup.c:
> net/netfilter/nft_lookup.c:133:12: warning: no previous prototype for=
 =E2=80=98nft_lookup_module_init=E2=80=99 [-Wmissing-prototypes]
> net/netfilter/nft_lookup.c:138:6: warning: no previous prototype for =
=E2=80=98nft_lookup_module_exit=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

>  net/netfilter/nft_lookup.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
> index 8a6116b..bb4ef4c 100644
> --- a/net/netfilter/nft_lookup.c
> +++ b/net/netfilter/nft_lookup.c
> @@ -16,6 +16,7 @@
>  #include <linux/netfilter.h>
>  #include <linux/netfilter/nf_tables.h>
>  #include <net/netfilter/nf_tables.h>
> +#include <net/netfilter/nf_tables_core.h>
> =20
>  struct nft_lookup {
>  	struct nft_set			*set;
> --=20
> 1.7.9.5
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
