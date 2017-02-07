From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Tue, 7 Feb 2017 15:19:25 -0700
Message-ID: <20170207221925.GA30579@obsidianresearch.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207211901.GB28922@obsidianresearch.com>
 <20170207220628.GB76652@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, dennis.dalessandro@intel.com,
        ira.weiny@intel.com, Liran Liss <liranl@mellanox.com>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:35255 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932313AbdBGWT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 17:19:29 -0500
Content-Disposition: inline
In-Reply-To: <20170207220628.GB76652@knc-06.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 02:06:30PM -0800, Vishwanathapura, Niranjana wrote:

> >> 	IB_DEVICE_RAW_SCATTER_FCS		= (1ULL << 34),
> >>+	IB_DEVICE_RDMA_NETDEV_HFI_VNIC		= (1ULL << 35),
> >
> >What is this called HFI_VNIC anyhow? Shouldn't this be OPA_VNIC? There
> >is nothing really HFI specific, right?
> 
> Agreed, OPA_VNIC is more appropriate here. Will change it.

And probably lots of other places too.. :)


> >And this should be rn->dev_priv ?
> 
> Yah, both will result in same behavior. But yah, what you are suggesting
> will remove any confusion. Will change in next PATCH series.

Only because the struct has no members, as soon as someone adds
something it would go booom.

Jason
