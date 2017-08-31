From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net-next v2 0/3] net/sched: Improve getting objects by
 indexes
Date: Thu, 31 Aug 2017 01:05:40 +0000
Message-ID: <VI1PR0501MB21431977FD1FCECC1D3AC1FCAB9D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
 <20170830.143915.721461254974312457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "mawilcox@microsoft.com" <mawilcox@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0089.outbound.protection.outlook.com ([104.47.1.89]:43184
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750822AbdHaBFn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 21:05:43 -0400
In-Reply-To: <20170830.143915.721461254974312457.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, August 31, 2017 5:39 AM
> To: Chris Mi <chrism@mellanox.com>
> Cc: netdev@vger.kernel.org; jhs@mojatatu.com;
> xiyou.wangcong@gmail.com; jiri@resnulli.us; mawilcox@microsoft.com
> Subject: Re: [patch net-next v2 0/3] net/sched: Improve getting objects b=
y
> indexes
>=20
> From: Chris Mi <chrism@mellanox.com>
> Date: Wed, 30 Aug 2017 02:31:56 -0400
>=20
> > Using current TC code, it is very slow to insert a lot of rules.
> >
> > In order to improve the rules update rate in TC, we introduced the
> > following two changes:
> >         1) changed cls_flower to use IDR to manage the filters.
> >         2) changed all act_xxx modules to use IDR instead of
> >            a small hash table
> >
> > But IDR has a limitation that it uses int. TC handle uses u32.
> > To make sure there is no regression, we add several new IDR APIs to
> > support unsigned long.
> >
> > v2
> > =3D=3D
> >
> > Addressed Hannes's comment:
> > express idr_alloc in terms of idr_alloc_ext and most of the other
> > functions
>=20
> Series applied, thanks.

Thank you, David,

-Chris
