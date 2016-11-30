From: Arun Easi <arun.easi@cavium.com>
Subject: Re: qed, qedi patchset submission
Date: Wed, 30 Nov 2016 09:15:28 -0800
Message-ID: <alpine.LRH.2.00.1611300858390.28058@mvluser05.qlc.com>
References: <alpine.LRH.2.00.1611141256340.28058@mvluser05.qlc.com> <yq11sydfwts.fsf@sermon.lab.mkp.net> <alpine.LRH.2.00.1611291452030.28058@mvluser05.qlc.com> <yq1oa0wj4qy.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <yq1oa0wj4qy.fsf@sermon.lab.mkp.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the response, Martin.

On Wed, 30 Nov 2016, 8:45am, Martin K. Petersen wrote:

> >>>>> "Arun" == Arun Easi <arun.easi@cavium.com> writes:
> 
> Arun,
> 
> Arun> So far, we have been posting qedi changes split into functional
> Arun> blocks, for review, but was not bisectable. With Martin ok to our
> Arun> request to squash all patches while committing to tree, we were
> Arun> wondering if we should post the qedi patches squashed, with all
> Arun> the Reviewed-by added, or continue to post as before?
> 
> I guess it depends how things can be split up in a bisectable fashion.

These were the patches that was sent:
  1 qed: Add support for hardware offloaded iSCSI.
  2 qed: Add iSCSI out of order packet handling.
  3 qedi: Add QLogic FastLinQ offload iSCSI driver framework.
  4 qedi: Add LL2 iSCSI interface for offload iSCSI.
  5 qedi: Add support for iSCSI session management.
  6 qedi: Add support for data path.

> 
> If the net/ pieces can be completely separated from the scsi/ pieces
> maybe it would be best to have two patches?
> 

Yes, those pieces can be completely separated; there are actually 3 parts, 
2 that goes to net/ and 1 to scsi/.

In the list above, 1 & 2 goes to net/ and are bisectable. 3 through 6 are 
scsi/ pieces, which are the ones requested for collapsing.

We will post these pieces for V3, then:

  1 [PATCH v3 net-next 1/3] qed: Add support for hardware offloaded iSCSI.
  2 [PATCH v3 net-next 2/3] qed: Add iSCSI out of order packet handling.
  3 [PATCH v3 3/3] qedi: Add QLogic FastLinQ offload iSCSI driver framework.

Regards,
-Arun
