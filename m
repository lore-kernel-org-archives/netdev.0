From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 0/7] bnx2x: PTP crash, VF VLAN fixes
Date: Sun, 5 Mar 2017 10:17:11 +0000
Message-ID: <BL2PR07MB2306E8620E0EB1ED750C4B458D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Michal Schmidt <mschmidt@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0062.outbound.protection.outlook.com ([104.47.37.62]:33617
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751539AbdCEKRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Mar 2017 05:17:16 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hello,
> here are fixes for a crash with PTP, a crash in setting of VF multicast
> addresses, and non-working VLAN filters configuration from the VF side.
>=20
> Michal Schmidt (7):
>   bnx2x: prevent crash when accessing PTP with interface down
>   bnx2x: lower verbosity of VF stats debug messages
>   bnx2x: fix possible overrun of VFPF multicast addresses array
>   bnx2x: fix detection of VLAN filtering feature for VF
>   bnx2x: do not rollback VF MAC/VLAN filters we did not configure
>   bnx2x: fix incorrect filter count in an error message
>   bnx2x: add missing configuration of VF VLAN filters
>=20
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 36
> ++++++++++++++++----  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> | 15 ++++++---  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  1 +
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 40
> ++++++++++++++++-------
>  4 files changed, 70 insertions(+), 22 deletions(-)

Had a couple of questions/comments, but no real objections.
Thanks Michal!

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
[For the entire series]
