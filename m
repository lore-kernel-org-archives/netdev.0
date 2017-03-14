From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v1 for accelerated IPoIB 04/25] IB/verb: Add ipoib_options
 struct and API
Date: Tue, 14 Mar 2017 10:11:49 -0600
Message-ID: <20170314161149.GA15752@obsidianresearch.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-5-git-send-email-erezsh@mellanox.com>
 <20170313200136.GA2738@obsidianresearch.com>
 <20170314070109.GD79937@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erez Shitrit <erezsh@mellanox.com>, dledford@redhat.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:55848 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751042AbdCNQL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 12:11:59 -0400
Content-Disposition: inline
In-Reply-To: <20170314070109.GD79937@knc-06.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 12:01:09AM -0700, Vishwanathapura, Niranjana wrote:
> On Mon, Mar 13, 2017 at 02:01:36PM -0600, Jason Gunthorpe wrote:
> >>+	/* multicast */
> >>+	int (*attach_mcast)(struct net_device *dev, struct ib_device *hca,
> >>+			    union ib_gid *gid, u16 lid, int set_qkey);
> >>+	int (*detach_mcast)(struct net_device *dev, struct ib_device *hca,
> >>+			    union ib_gid *gid, u16 lid);
> >
> >It would make more sense to store the struct ib_device pointer in the
> >struct rdma_netdev.
> >
> 
> Agree that it shouldn't be a function parameters.
> For opa_vnic, I found it convenient to store ib_device pointer in client and
> device private structures as those will be available in most places anyhow.

If vnic uses it too, then lets add the ib_device and port num to
rdma_netdev itself?

Jason
