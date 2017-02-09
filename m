From: Dexuan Cui <decui@microsoft.com>
Subject: Mellanox ConnectX-3 VF driver can't work with 16 CPUs?
Date: Thu, 9 Feb 2017 10:03:20 +0000
Message-ID: <MWHPR03MB2669F7138EE9DE92A372C863BF450@MWHPR03MB2669.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0119.outbound.protection.outlook.com ([104.47.36.119]:19264
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752153AbdBIKDf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 05:03:35 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,=20
While trying SR-IOV with a Linux guest running on Hyper-V, I found this iss=
ue:
the VF driver can't work if the guest has 16 virtual CPUs (less vCPUs, e.g.=
 8,  can work fine):

[    9.927820] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
[    9.927882] mlx4_core: Initializing b961:00:02.0
[    9.970994] mlx4_core b961:00:02.0: Detected virtual function - running =
in slave mode
[    9.976783] mlx4_core b961:00:02.0: Sending reset
[    9.985858] mlx4_core b961:00:02.0: Sending vhcr0
[   10.004855] mlx4_core b961:00:02.0: HCA minimum page size:512
[   10.010465] mlx4_core b961:00:02.0: Timestamping is not supported in sla=
ve mode
[   10.203065] mlx4_core b961:00:02.0: Failed to initialize event queue tab=
le, aborting
[   10.226728] mlx4_core: probe of b961:00:02.0 failed with error -12

I'm using the mainline kernel (4.10.0-rc4).

Any idea?

Thanks,
-- Dexuan
