From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [RFC v1 for accelerated IPoIB 04/25] IB/verb: Add ipoib_options
 struct and API
Date: Tue, 14 Mar 2017 00:01:09 -0700
Message-ID: <20170314070109.GD79937@knc-06.sc.intel.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-5-git-send-email-erezsh@mellanox.com>
 <20170313200136.GA2738@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Erez Shitrit <erezsh@mellanox.com>, dledford@redhat.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42853 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750715AbdCNHBW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 03:01:22 -0400
Content-Disposition: inline
In-Reply-To: <20170313200136.GA2738@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 02:01:36PM -0600, Jason Gunthorpe wrote:
>> +	/* multicast */
>> +	int (*attach_mcast)(struct net_device *dev, struct ib_device *hca,
>> +			    union ib_gid *gid, u16 lid, int set_qkey);
>> +	int (*detach_mcast)(struct net_device *dev, struct ib_device *hca,
>> +			    union ib_gid *gid, u16 lid);
>
>It would make more sense to store the struct ib_device pointer in the
>struct rdma_netdev.
>

Agree that it shouldn't be a function parameters.
For opa_vnic, I found it convenient to store ib_device pointer in client and 
device private structures as those will be available in most places anyhow.

Niranjana
