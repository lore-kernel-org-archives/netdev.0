From: Arun Easi <arun.easi@cavium.com>
Subject: Re: qed, qedi patchset submission
Date: Tue, 29 Nov 2016 15:11:26 -0800
Message-ID: <alpine.LRH.2.00.1611291452030.28058@mvluser05.qlc.com>
References: <alpine.LRH.2.00.1611141256340.28058@mvluser05.qlc.com> <yq11sydfwts.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <yq11sydfwts.fsf@sermon.lab.mkp.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

As we are preparing to post V3 of the qed (drivers/net/) and qedi 
(drivers/scsi/), I would like to get your opinion on the "qedi" part. As 
qedi (the iSCSI driver) is dependent on the accompanying "qed" changes, 
qedi changes have to follow or be together with qed changes. Martin is ok 
in having you taking the qedi part as well (see below discussion) or wait 
until qed is in, and then take qedi through SCSI tree.

Hi David, Martin,

So far, we have been posting qedi changes split into functional blocks, 
for review, but was not bisectable. With Martin ok to our request to 
squash all patches while committing to tree, we were wondering if we 
should post the qedi patches squashed, with all the Reviewed-by added, or 
continue to post as before?

Regards,
-Arun

On Mon, 14 Nov 2016, 3:47pm, Martin K. Petersen wrote:

> >>>>> "Arun" == Arun Easi <arun.easi@cavium.com> writes:
> 
> Arun,
> 
> Arun> Do you have any preference or thoughts on how the "qed" patches be
> Arun> approached? Just as a reference, our rdma driver "qedr" went
> Arun> through something similar[1], and eventually "qed" patches were
> Arun> taken by David in the net tree and "qedr", in the rdma tree
> Arun> (obviously) by Doug L.
> 
> DaveM can queue the whole series or I can hold the SCSI pieces for
> rc1. Either way works for me.
> 
> However, I would like to do a review of the driver first. I will try to
> get it done this week.
> 
> 
