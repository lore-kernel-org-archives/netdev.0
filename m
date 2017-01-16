From: Chad Dupuis <chad.dupuis@cavium.com>
Subject: Re: [PATCH 1/2] qed: Add support for hardware offloaded FCoE.
Date: Mon, 16 Jan 2017 16:47:52 -0500
Message-ID: <alpine.OSX.2.00.1701161633290.2060@administrators-macbook-pro.local>
References: <1484596437-27637-1-git-send-email-chad.dupuis@cavium.com> <1484596437-27637-2-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <linux-scsi@vger.kernel.org>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <yuval.mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>
To: <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0052.outbound.protection.outlook.com ([104.47.33.52]:19680
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750877AbdAPVsM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 16:48:12 -0500
In-Reply-To: <1484596437-27637-2-git-send-email-chad.dupuis@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to add netdev-next to the subject line.  Is a repost needed here?

On Mon, 16 Jan 2017, 7:53pm -0000, Dupuis, Chad wrote:

> From: Arun Easi <arun.easi@qlogic.com>
> 
> This adds the backbone required for the various HW initalizations
> which are necessary for the FCoE driver (qedf) for QLogic FastLinQ
> 4xxxx line of adapters - FW notification, resource initializations, etc.
> 
> Signed-off-by: Arun Easi <arun.easi@cavium.com>
> Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
> ---
>  drivers/net/ethernet/qlogic/Kconfig               |   3 +
>  drivers/net/ethernet/qlogic/qed/Makefile          |   1 +
>  drivers/net/ethernet/qlogic/qed/qed.h             |  11 +
>  drivers/net/ethernet/qlogic/qed/qed_cxt.c         |  98 ++-
>  drivers/net/ethernet/qlogic/qed/qed_cxt.h         |   3 +
>  drivers/net/ethernet/qlogic/qed/qed_dcbx.c        |  11 +
>  drivers/net/ethernet/qlogic/qed/qed_dcbx.h        |   1 +
>  drivers/net/ethernet/qlogic/qed/qed_dev.c         | 205 ++++-
>  drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |  42 +
>  drivers/net/ethernet/qlogic/qed/qed_fcoe.c        | 990 ++++++++++++++++++++++
>  drivers/net/ethernet/qlogic/qed/qed_fcoe.h        |  52 ++
>  drivers/net/ethernet/qlogic/qed/qed_hsi.h         | 781 ++++++++++++++++-
>  drivers/net/ethernet/qlogic/qed/qed_hw.c          |   3 +
>  drivers/net/ethernet/qlogic/qed/qed_ll2.c         |  25 +
>  drivers/net/ethernet/qlogic/qed/qed_ll2.h         |   2 +-
>  drivers/net/ethernet/qlogic/qed/qed_main.c        |   7 +
>  drivers/net/ethernet/qlogic/qed/qed_mcp.c         |   3 +
>  drivers/net/ethernet/qlogic/qed/qed_mcp.h         |   1 +
>  drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |   8 +
>  drivers/net/ethernet/qlogic/qed/qed_sp.h          |   4 +
>  drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |   3 +
>  include/linux/qed/common_hsi.h                    |  10 +-
>  include/linux/qed/fcoe_common.h                   | 715 ++++++++++++++++
>  include/linux/qed/qed_fcoe_if.h                   | 145 ++++
>  include/linux/qed/qed_if.h                        |  39 +
>  25 files changed, 3152 insertions(+), 11 deletions(-)
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.c
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.h
>  create mode 100644 include/linux/qed/fcoe_common.h
>  create mode 100644 include/linux/qed/qed_fcoe_if.h
> 
