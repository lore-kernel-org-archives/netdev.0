From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 3/7 v2] bnx2x: fix possible overrun of VFPF multicast
 addresses array
Date: Tue, 7 Mar 2017 15:54:35 +0000
Message-ID: <BL2PR07MB230674114D97A4A4EBB78F158D2F0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
 <20170303160834.4125-4-mschmidt@redhat.com>
 <BL2PR07MB230637FFDAFE26D2052B269F8D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <186b89fe-dbf4-ecc2-7c0c-0f2c37b846b8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Michal Schmidt <mschmidt@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0071.outbound.protection.outlook.com ([104.47.37.71]:54656
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755856AbdCGTeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 14:34:25 -0500
In-Reply-To: <186b89fe-dbf4-ecc2-7c0c-0f2c37b846b8@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It is too late to check for the limit of the number of VF multicast addre=
sses
> after they have already been copied to the req->multicast[] array, possib=
ly
> overflowing it.
>=20
> Do the check before copying.
>=20
> Checking early also avoids having to (and forgetting to) unlock vf2pf_mut=
ex.
>=20
> While we're looking at the error paths in the function, also return an er=
ror
> code from it when the PF responds with an error. Even though the caller
> ignores it.
>=20
> v2: Move the check before bnx2x_vfpf_prep() as suggested by Yuval.
>=20
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com
