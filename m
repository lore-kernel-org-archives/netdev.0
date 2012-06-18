From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 01/12] netfilter: fix problem with proto
 register
Date: Mon, 18 Jun 2012 11:06:31 +0200
Message-ID: <20120618090631.GA27067@1984>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
 <20120616105037.GA18251@1984>
 <4FDE7D5F.5080703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47212 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752715Ab2FRJGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 05:06:34 -0400
Content-Disposition: inline
In-Reply-To: <4FDE7D5F.5080703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 18, 2012 at 08:59:11AM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8816=E6=97=A5 18:50, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Sat, Jun 16, 2012 at 11:41:12AM +0800, Gao feng wrote:
> >> commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448
> >> (netfilter: nf_conntrack: prepare namespace support for
> >> l4 protocol trackers) register proto before register sysctl.
> >>
> >> it changes the behavior that when register sysctl failed, the
> >> proto should not be registered too.
> >>
> >> so change to register sysctl before register protos.
> >=20
> > Could you explain why we need to change the order in the registrati=
on?
> > ie. now first proto->init_net then sysctl things.
>=20
> before commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448, we register s=
ysctl before
> register protos, so if sysctl is registered faild, the protos will no=
t be registered.
>=20
> but now, we register protos first, and when register sysctl failed, w=
e can use protos
> too, it's different from before.

That makes sense.

IMO, this is the thing that should be included in the description.
