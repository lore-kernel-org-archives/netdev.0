From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net] qed: Unlock on error in qed_vf_pf_acquire()
Date: Sun, 30 Apr 2017 07:54:32 +0000
Message-ID: <BLUPR0701MB200472744FABF8DA1E2118BE8D150@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170428125608.djln5r7h4d53it5s@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0078.outbound.protection.outlook.com ([104.47.36.78]:51520
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1167089AbdD3Hyg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 03:54:36 -0400
In-Reply-To: <20170428125608.djln5r7h4d53it5s@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> My static checker complains that we're holding a mutex on this error path=
.
> Let's goto exit instead of returning directly.
>=20
> Fixes: b0bccb69eba3 ("qed: Change locking scheme for VF channel")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Yuval, could you review this one a bit carefully and also check that my F=
ixes
> tag is correct because I'm not certain.

Yes it seems like the right one. Thanks!

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
