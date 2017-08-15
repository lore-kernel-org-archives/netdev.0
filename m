From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 iproute2 1/7] rdma: Add basic infrastructure for RDMA
 tool
Date: Tue, 15 Aug 2017 16:54:16 -0700
Message-ID: <20170815165416.24e9838a@xeon-e3>
References: <20170815130020.29509-1-leonro@mellanox.com>
        <20170815130020.29509-2-leonro@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:37290 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752243AbdHOXyX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 19:54:23 -0400
Received: by mail-pg0-f41.google.com with SMTP id y129so14831800pgy.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 16:54:23 -0700 (PDT)
In-Reply-To: <20170815130020.29509-2-leonro@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Aug 2017 16:00:14 +0300
Leon Romanovsky <leonro@mellanox.com> wrote:

> RDMA devices are cross-functional devices from one side,
> but very tailored for the specific markets from another.
> 
> Such diversity caused to spread of RDMA related configuration
> across various tools, e.g. devlink, ip, ethtool, ib specific and
> vendor specific solutions.
> 
> This patch adds ability to fill device and port information
> by reading RDMA netlink.
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

Won't build for me.

$ make distclean

$ make

In file included from rdma.c:12:0:
rdma.h:23:23: fatal error: rdma/rdma.h: No such file or directory
 #include <rdma/rdma.h>
                       ^

I think your Makefile expects something different.
Or more Config fallout
