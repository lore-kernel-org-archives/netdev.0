From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net: ipv6: change %8s to %s for seq_printf of if6_seq_stop
Date: Tue, 06 Nov 2012 09:11:52 +0800
Message-ID: <509863D8.9020501@asianux.com>
References: <5097A030.5030209@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:3620 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab2KFBKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 20:10:51 -0500
In-Reply-To: <5097A030.5030209@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA11=D4=C205=C8=D5 19:17, Chen Gang =D0=B4=B5=C0:
>=20
>   the length of ifp->idev->dev->name is 16 (IFNAMSIZ)
>   in seq_printf, it is not suitable to use %8s for rt->dst.dev->name.
>   so change it to %s, since each line has not been solid any more.
>=20

1) sorry, the comments is incorrect
   need use ifp->idev->dev->name instead of rt->dst.dev->name in 2nd li=
ne.
   I will send it again.

2) By the way, the three patches "* %8s to %s *" are almost the same
   If need merge them into one patch, please tell me, I shall do.

   thanks.

--=20
Chen Gang

Asianux Corporation
