From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH rdma-next v1 10/12] IB/hfi1: OPA_VNIC RDMA netdev support
Date: Wed, 12 Apr 2017 09:56:21 -0600
Message-ID: <20170412155621.GC14409@obsidianresearch.com>
References: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1491979207-18686-11-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1491979207-18686-11-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 11, 2017 at 11:40:05PM -0700, Vishwanathapura, Niranjana wrote:
> Add support to create and free OPA_VNIC rdma netdev devices.
> Implement netstack interface functionality including xmit_skb,
> receive side NAPI etc. Also implement rdma netdev control functions.

Now that you have all this infrastructure, and Erez as produced a
ipoib patch to use it, are you going to look at implementing the ipoib
rdma_netdev variant too?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
