From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH rdma-next 09/19] RDMA/netlink: Add and implement doit netlink callback
Date: Wed, 21 Jun 2017 09:11:45 -0500
Message-ID: <022601d2ea98$50748db0$f15da910$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-10-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma@vger.kernel.org>,
        "'Chien Tin Tung'" <chien.tin.tung@intel.com>,
        "'Stephen Hemminger'" <stephen@networkplumber.org>,
        "'Jiri Pirko'" <jiri@mellanox.com>,
        "'Ariel Almog'" <ariela@mellanox.com>,
        "'Linux Netdev'" <netdev@vger.kernel.org>,
        "'Leon Romanovsky'" <leonro@mellanox.com>
To: "'Leon Romanovsky'" <leon@kernel.org>,
        "'Doug Ledford'" <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:52576 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751041AbdFUOLm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 10:11:42 -0400
In-Reply-To: <20170621060528.3752-10-leon@kernel.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Leon Romanovsky <leonro@mellanox.com>
> 
> The .doit callback is used by netlink core to differentiate
> between get and set operations. Common convention is to use
> that call for command operations like (SET, ADD, e.t.c.) and/or
> access without NLF_M_DUMP flag.
> 
> This commit adds proper declaration and implementation
> to RDMA netlink.
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

Looks good.

Reviewed-by: Steve Wise <swise@opengridcomputing.com>
