From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH 11/17] mlx4_en: Enabling new steering
Date: Tue, 8 Mar 2011 13:30:25 -0800
Message-ID: <AANLkTim8XDT5YKJc4wroyEDJc1X+xZOFL9y_090F5eLr@mail.gmail.com>
References: <4D74B0C9.9020108@mellanox.co.il> <AANLkTikftARWMbmy8zHbRShBbbnQhXhiequzdR_aPBst@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>, davem@davemloft.net,
	netdev@vger.kernel.org, vlad@mellanox.co.il, nirmu@mellanox.com,
	Aleksey Senin <alekseys@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog111.obsmtp.com ([74.125.245.90]:52584 "HELO
	na3sys010aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755945Ab1CHVaq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 16:30:46 -0500
Received: by mail-ww0-f53.google.com with SMTP id 40so1711441wwj.10
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 13:30:45 -0800 (PST)
In-Reply-To: <AANLkTikftARWMbmy8zHbRShBbbnQhXhiequzdR_aPBst@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2011 at 1:10 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote=
:
>> + =A0 =A0 =A0 if (mdev->dev->caps.vep_mc_steering && ibqp->qp_type =3D=
=3D IB_QPT_RAW_ETHERTYPE) {
>
> Guys,
>
> Didn't you want to refer here to the "raw ethernet QP" which is typed
> to IB_QPT_RAW_PACKET by the series posted on December last year, see
> http://marc.info/?l=3Dlinux-rdma&m=3D129162076818154 =A0--
> IB_QPT_RAW_ETHERTYPE =A0is a rename of IB's IB_QPT_RAW_ETY done by
> commit a2ebf07ae53e65bd073f96877e4818f2e89271ae

Good catch.  I think the drivers/infiniband part of this patch should
just be dropped -- we don't have any raw QP support of any kind, right?

 - R.
