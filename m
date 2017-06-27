From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 11:37:35 -0600
Message-ID: <20170627173735.GA5162@obsidianresearch.com>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
 <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
 <20170627040604.GI1248@mtr-leonro.local>
 <20170627092129.GR1248@mtr-leonro.local>
 <20170627164150.GA4288@obsidianresearch.com>
 <20170627173301.GS1248@mtr-leonro.local>
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
Received: from quartz.orcorp.ca ([184.70.90.242]:54879 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752311AbdF0Rhy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 13:37:54 -0400
Content-Disposition: inline
In-Reply-To: <20170627173301.GS1248@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 08:33:01PM +0300, Leon Romanovsky wrote:

> My initial plan was to put all parsers under their respective names, in
> the similar way as I did for caps: $ rdma dev show mlx5_4 caps

I think you should have a useful summary display similar to 'ip a' and
other commands.

guid(s), subnet prefix or default gid for IB, lid/lmc, link state,
speed, mtu, pkeys protocol(s)

A show gid table command makes sense for rocee where it can show the
gid and the IP binding for it, rocee mode, etc..

Jason
