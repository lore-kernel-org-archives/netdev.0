From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH rdma-next v2 00/12] Omni-Path Virtual Network Interface
 Controller (VNIC)
Date: Thu, 20 Apr 2017 14:39:58 -0400
Message-ID: <1492713598.3041.2.camel@redhat.com>
References: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-12 at 20:29 -0700, Vishwanathapura, Niranjana wrote:
> ChangeLog:
> =========
> v1 => v2:
> a) Change error code for unsupported rdma netdev type
> b) Remove some debug messages
> 
> v1: posted @ https://www.spinics.net/lists/linux-rdma/msg48518.html
> 
> v0 => v1:
> a) changes as required by new kernel base (for-4.12)
> b) moved rdma netdev interface into a separate patch 
> c) Return specific error code if specified rdma netdev type is not
> supported
> d) Some minor fixes (no changes to overall design or interface)
> 
> v0: Initial post @ https://www.spinics.net/lists/linux-rdma/msg46604.
> html
> 
> Description:
> ============
> Intel Omni-Path (OPA) Virtual Network Interface Controller (VNIC)
> feature
> supports Ethernet functionality over Omni-Path fabric by
> encapsulating
> the Ethernet packets between HFI nodes.

I've pulled this into a custom branch based on DaveM's for-next tree so
that I could put the IPoIB changes into the same branch and the final
touchup patch Leon talked about into that branch as well.  So, this is
now queued for-next (albeit not on the normal branch).

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
