From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] qed: fix invalid use of sizeof in
 qed_alloc_qm_data()
Date: Tue, 25 Apr 2017 13:43:31 +0000
Message-ID: <BLUPR0701MB2004B6C989CAC99ADC7FAAA18D1E0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170425070718.14790-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0060.outbound.protection.outlook.com ([104.47.33.60]:28927
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1176646AbdDYNng (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 09:43:36 -0400
In-Reply-To: <20170425070718.14790-1-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> sizeof() when applied to a pointer typed expression gives the size of the
> pointer, not that of the pointed data.
>=20
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Thanks!
Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>

I'd also mention that -

Fixes: b5a9ee7cf3be ("qed: Revise QM configuration")
