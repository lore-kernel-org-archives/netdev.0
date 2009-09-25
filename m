From: "Karen Xie" <kxie@chelsio.com>
Subject: RE: [PATCH v2 0/2] cxgb3/cxgb3i: added support of private MAC address and provisioning packet handler for iSCSI
Date: Fri, 25 Sep 2009 15:34:22 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334066E7019@maui.asicdesigners.com>
References: <200909252225.n8PMPaqI031748@localhost.localdomain> <20090925.152430.119503066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <michaelc@cs.wisc.edu>, <James.Bottomley@HansenPartnership.com>,
	"Steve Wise" <swise@opengridcomputing.com>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Rakesh Ranjan" <rakesh@chelsio.com>, <linux-scsi@vger.kernel.org>,
	<open-iscsi@googlegroups.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hmm, I am wondering how could this merge activity to be coordinated? If
only the driver/scsi change is merged, then it won't compile either,
since it requires the driver/net change.

Is it possible to merge both patches to the scsi or net tree?

Thanks,
Karen

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, September 25, 2009 3:25 PM
To: Karen Xie
Cc: michaelc@cs.wisc.edu; James.Bottomley@HansenPartnership.com; Steve
Wise; Divy Le Ray; Rakesh Ranjan; linux-scsi@vger.kernel.org;
open-iscsi@googlegroups.com; linux-kernel@vger.kernel.org;
netdev@vger.kernel.org
Subject: Re: [PATCH v2 0/2] cxgb3/cxgb3i: added support of private MAC
address and provisioning packet handler for iSCSI

From: kxie@chelsio.com
Date: Fri, 25 Sep 2009 15:25:36 -0700

> From: Karen Xie <kxie@chelsio.com>
> 
> The two patches added support of private MAC address, which is derived
from
> the network (i.e., public) MAC address, and provisioning packet
handler for
> iSCSI traffic only.

I think I'm going to ask you to resubmit the drivers/net patch
after the necessary drivers/scsi changes get merged by the scsi
folks.

Thank you.
