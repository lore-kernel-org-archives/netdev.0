From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [Open-FCoE] [PATCH RFC net-next 1/5] qed: Add support for
 hardware offloaded FCoE.
Date: Thu, 29 Dec 2016 17:28:36 +0000
Message-ID: <BL2PR07MB2306CCCE99C9CEB761ADF5A08D6B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
 <1482520628-24207-2-git-send-email-chad.dupuis@cavium.com>
 <371bc2ac-c630-0e95-29aa-3fa16fe0c764@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "fcoe-devel@open-fcoe.org" <fcoe-devel@open-fcoe.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dept-Eng QLogic Storage Upstream"
        <QLogic-Storage-Upstream@cavium.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: Hannes Reinecke <hare@suse.de>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>,
        "martin.petersen@oracle.com" <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0056.outbound.protection.outlook.com ([104.47.33.56]:32448
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752820AbcL2RnU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 12:43:20 -0500
In-Reply-To: <371bc2ac-c630-0e95-29aa-3fa16fe0c764@suse.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +struct fcoe_tstorm_fcoe_task_st_ctx_read_write {
> > +	union fcoe_cleanup_addr_exp_ro_union
> cleanup_addr_exp_ro_union;
> > +	__le16 flags;
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_RX_SGL_MODE_MASK
> 0x7
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_RX_SGL_MODE_SHIFT      0
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_EXP_FIRST_FRAME_MASK
> 0x1
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_EXP_FIRST_FRAME_SHIFT
> 3
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_SEQ_ACTIVE_MASK
> 0x1
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_SEQ_ACTIVE_SHIFT       4
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_SEQ_TIMEOUT_MASK
> 0x1
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_SEQ_TIMEOUT_SHIFT      5
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_SINGLE_PKT_IN_EX_MASK
> 0x1
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_SINGLE_PKT_IN_EX_SHIFT
> 6
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_OOO_RX_SEQ_STAT_MAS
> K   0x1
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_OOO_RX_SEQ_STAT_SHIFT
> 7
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_CQ_ADD_ADV_MASK
> 0x3
> > +#define
> FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_CQ_ADD_ADV_SHIFT       8
> > +#define FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_RSRV1_MASK
> 0x3F
> > +#define FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_RSRV1_SHIFT
> 10
>=20
> A very odd way of defining a bitfield ...
> Why not use a 'normal' bitfield here?

This is the format of our generated firmware HSI; We already have
Thousands of definitions using this same format.
