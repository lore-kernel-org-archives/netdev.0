From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net] bnx2x: fix pf2vf bulletin DMA mapping leak
Date: Wed, 7 Jun 2017 14:23:40 +0000
Message-ID: <BLUPR0701MB2004C8CF7E47DD332FB527098DC80@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170606143031.863-1-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Michal Schmidt <mschmidt@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0047.outbound.protection.outlook.com ([104.47.37.47]:27622
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750810AbdFGOXm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 10:23:42 -0400
In-Reply-To: <20170606143031.863-1-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When freeing VF's DMA mappings, an already NULLed pointer was checked
> again due to an apparent copy&paste error. Consequently, the pf2vf bullet=
in
> DMA mapping was not freed.
>=20
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Thanks Michal.

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
