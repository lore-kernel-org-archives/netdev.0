From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/17] netfilter: add struct nf_proto_net for register
 l4proto sysctl
Date: Mon, 28 May 2012 11:53:02 +0200
Message-ID: <20120528095302.GA10379@1984>
References: <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523101200.GA2836@1984>
 <4FBD9076.6060309@cn.fujitsu.com>
 <20120524095859.GC13091@1984>
 <4FBE1372.60206@cn.fujitsu.com>
 <20120524143854.GA15898@1984>
 <4FBEDADE.8040905@cn.fujitsu.com>
 <20120525025451.GA21076@1984>
 <4FBF207D.80809@cn.fujitsu.com>
 <4FC03FD1.2050408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FC03FD1.2050408@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 26, 2012 at 10:28:33AM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8825=E6=97=A5 14:02, Gao feng =E5=86=99=
=E9=81=93:
> > =E4=BA=8E 2012=E5=B9=B405=E6=9C=8825=E6=97=A5 10:54, Pablo Neira Ay=
uso =E5=86=99=E9=81=93:
[...]
> >> Could you resolve this by checking pn->ctl_compat_header !=3D NULL=
 ?
> >=20
> > pn->ctl_table_header and ctl_compat_header is shared by l4proto_tcp=
 and l4proto_tcp6.
> > if we both register l4proto_tcp and l4proto_tcp6, when unregister l=
4proto_tcp6
> > pn->ctl_compat_header must not be NULL.
> >=20
>=20
> Maybe we can resolve this by  nf_conntrack_l4proto.l3proto =3D=3D AF_=
INET &&  pn->ctl_compat_header !=3D NULL
> Because compat sysctl is registered by AF_INET's proto only.

OK, as soon as it can remove the compat field, I prefer it.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
