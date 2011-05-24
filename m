From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2]net:8021q:vlan.c Fix pr_info to just give the vlan
 fullname and version.
Date: Mon, 23 May 2011 22:54:40 -0700
Message-ID: <1306216480.2298.1.camel@Joe-Laptop>
References: <1306215647-2857-1-git-send-email-justinmattock@gmail.com>
	 <1306215958.2638.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Justin P. Mattock" <justinmattock@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306215958.2638.29.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-24 at 07:45 +0200, Eric Dumazet wrote:
> Le lundi 23 mai 2011 =C3=A0 22:40 -0700, Justin P. Mattock a =C3=A9cr=
it :
> > The below patch removes vlan_buggyright and vlan_copyright from vla=
n_proto_init,=20
> > so that it prints out just the fullname of vlan and the version num=
ber.
[]
> > diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> > -	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyrigh=
t);
> > -	pr_info("All bugs added by %s\n", vlan_buggyright);
> > +	pr_info("%s v%s\n", vlan_fullname, vlan_version);
> > =20
> >  	err =3D register_pernet_subsys(&vlan_net_ops);
> >  	if (err < 0)
> This reminds me a discussion with Harald Welte in netfilter workshop
> 2010.
> Sometime these strings help lot guys working to fight GPL violations.

How so?
