From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] qed: Fix an off by one bug
Date: Wed, 14 Jun 2017 09:21:32 +0000
Message-ID: <BY2PR0701MB2005D7EC2C3C89C305AAF0508DC30@BY2PR0701MB2005.namprd07.prod.outlook.com>
References: <20170614091009.GA29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0080.outbound.protection.outlook.com ([104.47.32.80]:38848
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751888AbdFNJVp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 05:21:45 -0400
In-Reply-To: <20170614091009.GA29394@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The p_l2_info->pp_qid_usage[] array has "p_l2_info->queues" elements so
> the > here should be a >=3D or we write beyond the end of the array.
>=20
> Fixes: bbe3f233ec5e ("qed: Assign a unique per-queue index to queue-cid")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

While it's a theoretical fix [as check is defensive; the queue-id was suppo=
sed
to be validated before reaching this part], it's still the right. Thanks Da=
n.

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
