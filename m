From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH 1/1] net: ethernet: qlogic: set error code on failure
Date: Sun, 4 Dec 2016 07:29:58 +0000
Message-ID: <BL2PR07MB2306060C02F0A19BD735EBE28D800@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480830833-5084-1-git-send-email-bianpan201603@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Pan Bian <bianpan201603@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0077.outbound.protection.outlook.com ([104.47.36.77]:8704
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750882AbcLDHpe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Dec 2016 02:45:34 -0500
In-Reply-To: <1480830833-5084-1-git-send-email-bianpan201603@163.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Pan Bian <bianpan2016@163.com>
>=20
> When calling dma_mapping_error(), the value of return variable rc is 0.
> And when the call returns an unexpected value, rc is not set to a negativ=
e
> errno. Thus, it will return 0 on the error path, and its callers cannot d=
etect
> the bug. This patch fixes the bug, assigning "-ENOMEM" to err.
>=20
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D189041
>=20
> Signed-off-by: Pan Bian <bianpan2016@163.com>

The title should have been "[PATCH net 1/1] qed: Set error code on failure"=
.

But the fix itself is sound. Thanks.
BTW, is -ENOMEM the right return code in case of DMA mapping errors?

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
