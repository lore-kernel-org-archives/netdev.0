From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 10:41:50 -0600
Message-ID: <20170627164150.GA4288@obsidianresearch.com>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
 <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
 <20170627040604.GI1248@mtr-leonro.local>
 <20170627092129.GR1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:36468 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751639AbdF0Ql6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 12:41:58 -0400
Content-Disposition: inline
In-Reply-To: <20170627092129.GR1248@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 12:21:29PM +0300, Leon Romanovsky wrote:
> > What will be the output of such command?
> >  $ rdma dev show mlx5_4
> 
> ip-like style:
> 
> $ rdma dev show mlx5_4
> 5: mlx5_4:
>     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
> $ rdma link show mlx5_3
> 4/1: mlx5_3/1:
>     caps: <CM, IP_BASED_GIDS>

I think that is better, maybe it should only show under some kind of
verbose mode, I don't know, it depends what other stuff ends up being
displayed..

Are you going to dump the gid table and pkey table too in one of these commands?

Jason
