From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [PATCH rdma-next v1 10/12] IB/hfi1: OPA_VNIC RDMA netdev support
Date: Wed, 12 Apr 2017 11:38:35 -0700
Message-ID: <20170412183835.GB19704@knc-06.sc.intel.com>
References: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1491979207-18686-11-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170412155621.GC14409@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, dennis.dalessandro@intel.com,
        ira.weiny@intel.com,
        Andrzej Kacprowski <andrzej.kacprowski@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:14834 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752286AbdDLSig (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 14:38:36 -0400
Content-Disposition: inline
In-Reply-To: <20170412155621.GC14409@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 09:56:21AM -0600, Jason Gunthorpe wrote:
>On Tue, Apr 11, 2017 at 11:40:05PM -0700, Vishwanathapura, Niranjana wrote:
>> Add support to create and free OPA_VNIC rdma netdev devices.
>> Implement netstack interface functionality including xmit_skb,
>> receive side NAPI etc. Also implement rdma netdev control functions.
>
>Now that you have all this infrastructure, and Erez as produced a
>ipoib patch to use it, are you going to look at implementing the ipoib
>rdma_netdev variant too?

For hfi1? Yah, I can give it a try later once both these patch series gets 
accepted (to avoid any rework or duplicate work).

Niranjana

>
