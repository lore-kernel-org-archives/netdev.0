From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 11/17] mlx4_en: Enabling new steering
Date: Tue, 8 Mar 2011 23:10:19 +0200
Message-ID: <AANLkTikftARWMbmy8zHbRShBbbnQhXhiequzdR_aPBst@mail.gmail.com>
References: <4D74B0C9.9020108@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, vlad@mellanox.co.il,
	Roland Dreier <roland@kernel.org>, nirmu@mellanox.com,
	Aleksey Senin <alekseys@mellanox.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39359 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594Ab1CHVKV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 16:10:21 -0500
Received: by wya21 with SMTP id 21so376259wya.19
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 13:10:20 -0800 (PST)
In-Reply-To: <4D74B0C9.9020108@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:

> +++ b/drivers/infiniband/hw/mlx4/main.c
> @@ -623,6 +623,14 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp=
, union

[...]
> + =A0 =A0 =A0 if (mdev->dev->caps.vep_mc_steering && ibqp->qp_type =3D=
=3D IB_QPT_RAW_ETHERTYPE) {

Guys,

Didn't you want to refer here to the "raw ethernet QP" which is typed
to IB_QPT_RAW_PACKET by the series posted on December last year, see
http://marc.info/?l=3Dlinux-rdma&m=3D129162076818154  --
IB_QPT_RAW_ETHERTYPE  is a rename of IB's IB_QPT_RAW_ETY done by
commit a2ebf07ae53e65bd073f96877e4818f2e89271ae

Or.
