From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH v2 5/6] qedi: Add support for iSCSI session management.
Date: Fri, 11 Nov 2016 17:47:37 +0100
Message-ID: <e74f2c3d-c0bb-cd3a-b33a-246f0946c73e@suse.de>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
 <1478588223-16183-6-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        QLogic-Storage-Upstream@cavium.com, Yuval.Mintz@cavium.com
To: Manish Rangankar <manish.rangankar@cavium.com>,
        martin.petersen@oracle.com, lduncan@suse.com, cleech@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58017 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934564AbcKKRDu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 12:03:50 -0500
In-Reply-To: <1478588223-16183-6-git-send-email-manish.rangankar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2016 07:57 AM, Manish Rangankar wrote:
> This patch adds support for iscsi_transport LLD Login,
> Logout, NOP-IN/NOP-OUT, Async, Reject PDU processing
> and Firmware async event handling support.
>
> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> Signed-off-by: Arun Easi <arun.easi@cavium.com>
> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> ---
>  drivers/scsi/qedi/qedi_fw.c    | 1106 +++++++++++++++++++++++++++
>  drivers/scsi/qedi/qedi_gbl.h   |   67 ++
>  drivers/scsi/qedi/qedi_iscsi.c | 1611 ++++++++++++++++++++++++++++++++++++++++
>  drivers/scsi/qedi/qedi_iscsi.h |  232 ++++++
>  drivers/scsi/qedi/qedi_main.c  |  166 +++++
>  5 files changed, 3182 insertions(+)
>  create mode 100644 drivers/scsi/qedi/qedi_fw.c
>  create mode 100644 drivers/scsi/qedi/qedi_gbl.h
>  create mode 100644 drivers/scsi/qedi/qedi_iscsi.c
>  create mode 100644 drivers/scsi/qedi/qedi_iscsi.h
>
Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: J. Hawn, J. Guild, F. Imendörffer, HRB 16746 (AG Nürnberg)
