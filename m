From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 10/12] netfilter: sctp proto sysctl support for net
 namespace
Date: Tue, 17 Apr 2012 13:29:40 +0200
Message-ID: <20120417112940.GA2956@1984>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1334631383-12326-11-git-send-email-gaofeng@cn.fujitsu.com>
 <4F8D4636.2080906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48396 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754265Ab2DQL3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 07:29:50 -0400
Content-Disposition: inline
In-Reply-To: <4F8D4636.2080906@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 06:30:14PM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B404=E6=9C=8817=E6=97=A5 10:56, Gao feng =E5=86=99=
=E9=81=93:
> > register pernet_operations nf_conntrack_net_proto_sctp_ops
> > when loading nf_conntrack_proto_sctp module,and unregister
> > it when removing.
> >=20
> > It makes no senes to register subsys for sctp and sctp6,because
> > the nf_conntrack_l4proto_sctp4 and nf_conntrack_l4proto_sctp6 are
> > register or unregister together.
> >=20
> > Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>=20
>=20
> I think it's better to impletement this as dccp,
> dccp stores the timeouts and ctl_table in net_generic.
>=20
> This will don't cause waste when sctp module is not loaded.

Agreed.
