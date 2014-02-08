From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 07/13] net: Move prototype declaration to header file
 include/net/dn.h from net/decnet/af_decnet.c
Date: Sat, 8 Feb 2014 12:11:21 -0800
Message-ID: <20140208201120.GG20885@leaf>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
 <45e9dd39b342bfb2308b75bd2b539de2c63bd6cb.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steffen Hurrle <steffen@hurrle.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <45e9dd39b342bfb2308b75bd2b539de2c63bd6cb.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 09, 2014 at 01:29:55AM +0530, Rashika Kheria wrote:
> Move prototype declaration of functions to header file include/net/dn=
=2Eh
> from net/decnet/af_decnet.c because they are used by more than one fi=
le.
>=20
> This eliminates the following warning in net/decnet/af_decnet.c:
> net/decnet/sysctl_net_decnet.c:354:6: warning: no previous prototype =
for =E2=80=98dn_register_sysctl=E2=80=99 [-Wmissing-prototypes]
> net/decnet/sysctl_net_decnet.c:359:6: warning: no previous prototype =
for =E2=80=98dn_unregister_sysctl=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

>  include/net/dn.h       |    2 ++
>  net/decnet/af_decnet.c |    3 ---
>  2 files changed, 2 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/net/dn.h b/include/net/dn.h
> index ccc1558..913b73d 100644
> --- a/include/net/dn.h
> +++ b/include/net/dn.h
> @@ -200,6 +200,8 @@ static inline void dn_sk_ports_copy(struct flowid=
n *fld, struct dn_scp *scp)
>  }
> =20
>  unsigned int dn_mss_from_pmtu(struct net_device *dev, int mtu);
> +void dn_register_sysctl(void);
> +void dn_unregister_sysctl(void);
> =20
>  #define DN_MENUVER_ACC 0x01
>  #define DN_MENUVER_USR 0x02
> diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
> index 24d9193..4c04848 100644
> --- a/net/decnet/af_decnet.c
> +++ b/net/decnet/af_decnet.c
> @@ -2351,9 +2351,6 @@ static const struct proto_ops dn_proto_ops =3D =
{
>  	.sendpage =3D	sock_no_sendpage,
>  };
> =20
> -void dn_register_sysctl(void);
> -void dn_unregister_sysctl(void);
> -
>  MODULE_DESCRIPTION("The Linux DECnet Network Protocol");
>  MODULE_AUTHOR("Linux DECnet Project Team");
>  MODULE_LICENSE("GPL");
> --=20
> 1.7.9.5
>=20
