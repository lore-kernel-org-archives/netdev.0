From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next v2 06/12] netfilter: merge udpv[4,6]_net_init
 into udp_net_init
Date: Tue, 19 Jun 2012 16:12:56 +0800
Message-ID: <4FE03488.3070404@cn.fujitsu.com>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com> <1339818083-31356-6-git-send-email-gaofeng@cn.fujitsu.com> <20120616112259.GG18251@1984> <4FE0337F.6030000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:34374 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab2FSIMc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 04:12:32 -0400
In-Reply-To: <4FE0337F.6030000@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8819=E6=97=A5 16:08, Gao feng =E5=86=99=
=E9=81=93:
>=20
> in order to implement it, we have to change the logic of
> nf_ct_l4proto_unregister_sysctl and nf_ct_unregister_sysctl. because =
we
> only free the sysctl table when we unregister the proto.

I means free the sysctl table when we register sysctl success
(pn->ctl_table_header !=3D NULL).
