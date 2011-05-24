From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2]net:8021q:vlan.c Fix pr_info to just give the vlan
 fullname and version.
Date: Tue, 24 May 2011 07:45:58 +0200
Message-ID: <1306215958.2638.29.camel@edumazet-laptop>
References: <1306215647-2857-1-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306215647-2857-1-git-send-email-justinmattock@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 23 mai 2011 =C3=A0 22:40 -0700, Justin P. Mattock a =C3=A9crit=
 :
> The below patch removes vlan_buggyright and vlan_copyright from vlan_=
proto_init,=20
> so that it prints out just the fullname of vlan and the version numbe=
r.
>=20
> before:
>=20
> [   30.438203] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelate=
ch.com>
> [   30.441542] All bugs added by David S. Miller <davem@redhat.com>
>=20
> after:
>=20
> [   31.513910] 802.1Q VLAN Support v1.8
>=20
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
> CC: Joe Perches <joe@perches.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Ben Greear <greearb@candelatech.com>
> ---
>  net/8021q/vlan.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index b2274d1..9df3fcb 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -673,8 +673,7 @@ static int __init vlan_proto_init(void)
>  {
>  	int err;
> =20
> -	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright)=
;
> -	pr_info("All bugs added by %s\n", vlan_buggyright);
> +	pr_info("%s v%s\n", vlan_fullname, vlan_version);
> =20
>  	err =3D register_pernet_subsys(&vlan_net_ops);
>  	if (err < 0)

This reminds me a discussion with Harald Welte in netfilter workshop
2010.

Sometime these strings help lot guys working to fight GPL violations.
