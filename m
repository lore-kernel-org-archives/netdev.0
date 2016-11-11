From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH v2 2/6] qed: Add iSCSI out of order packet handling.
Date: Fri, 11 Nov 2016 16:59:28 +0100
Message-ID: <40d086c4-e22b-521a-3b06-83a7e949ea00@suse.de>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
 <1478588223-16183-3-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        QLogic-Storage-Upstream@cavium.com, Yuval.Mintz@cavium.com
To: Manish Rangankar <manish.rangankar@cavium.com>,
        martin.petersen@oracle.com, lduncan@suse.com, cleech@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33306 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751606AbcKKP7b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 10:59:31 -0500
In-Reply-To: <1478588223-16183-3-git-send-email-manish.rangankar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2016 07:56 AM, Manish Rangankar wrote:
> From: Yuval Mintz <Yuval.Mintz@cavium.com>
>
> This patch adds out of order packet handling for hardware offloaded
> iSCSI. Out of order packet handling requires driver buffer allocation
> and assistance.
>
> Signed-off-by: Arun Easi <arun.easi@cavium.com>
> Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
> ---
>  drivers/net/ethernet/qlogic/qed/Makefile   |   2 +-
>  drivers/net/ethernet/qlogic/qed/qed.h      |   1 +
>  drivers/net/ethernet/qlogic/qed/qed_dev.c  |  14 +-
>  drivers/net/ethernet/qlogic/qed/qed_ll2.c  | 503 ++++++++++++++++++++++++++++-
>  drivers/net/ethernet/qlogic/qed/qed_ll2.h  |   9 +
>  drivers/net/ethernet/qlogic/qed/qed_ooo.c  | 501 ++++++++++++++++++++++++++++
>  drivers/net/ethernet/qlogic/qed/qed_ooo.h  | 173 ++++++++++
>  drivers/net/ethernet/qlogic/qed/qed_roce.c |   1 +
>  drivers/net/ethernet/qlogic/qed/qed_spq.c  |   9 +
>  9 files changed, 1201 insertions(+), 12 deletions(-)
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ooo.c
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ooo.h
>
Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: J. Hawn, J. Guild, F. Imendörffer, HRB 16746 (AG Nürnberg)
