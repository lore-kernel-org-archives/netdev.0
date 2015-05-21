From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Thu, 21 May 2015 12:56:43 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FDE09C@ORSMSX109.amr.corp.intel.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com>
 <5551A2CB.1010407@mellanox.com> <20150512185447.GA3503@obsidianresearch.com>
 <55532566.9040105@mellanox.com>
 <20150513165823.GA20343@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3@ORSMSX109.amr.corp.intel.com>
 <20150519192353.GA23612@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDD412@ORSMSX109.amr.corp.intel.com>
 <20150519234654.GA26634@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDD565@ORSMSX109.amr.corp.intel.com>
 <555D806B.1090002@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <555D806B.1090002-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> It remains to clean up ib_cm's ib_cm_listen interface now that
> compare_data isn't used, but I'm not sure this belongs in this series.

This patch series is changing the behavior that the compare data solves.  Currently, the ib_cm handles all of the multiplexing for the rdma_cm -- that's the reason for the compare data.  This series changes that such that the ib_cm would handle half the multiplexing, with the other half handled by the rdma_cm.  We should not insert that sort of split.  So, I disagree that this isn't part of this series.

Either do all of the multiplexing in the ib_cm -- without exposing it to inet (add port/pkey filtering if that works) -- or move all of it out.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
