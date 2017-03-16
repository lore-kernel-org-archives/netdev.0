From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v1 for accelerated IPoIB 04/25] IB/verb: Add ipoib_options
 struct and API
Date: Thu, 16 Mar 2017 10:04:34 -0600
Message-ID: <20170316160434.GC23821@obsidianresearch.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-5-git-send-email-erezsh@mellanox.com>
 <20170313200136.GA2738@obsidianresearch.com>
 <CAAk-MO8vPepHWHF_2GMbtC3yyxht1VFs=3Gu1r+drDs7ZbdpOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erez Shitrit <erezsh@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev@vger.kernel.org, valex@mellanox.com,
        Leon Romanovsky <leonro@mellanox.com>, saedm@mellanox.com
To: Erez Shitrit <erezsh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33866 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752103AbdCPQFM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 12:05:12 -0400
Content-Disposition: inline
In-Reply-To: <CAAk-MO8vPepHWHF_2GMbtC3yyxht1VFs=3Gu1r+drDs7ZbdpOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 05:17:55PM +0200, Erez Shitrit wrote:
 
> The QP as a part of the HW resources, it is created in the low-level
> driver, and used by the upper ipoib for few reasons, (for example the
> mac of the ipoib interface includes from the qp_num)
> Now, if we want to use the ndo's init/uninit i need to store member
> variables (qp_num and context) in the rdma_netdev, that will let me
> use the ndos as is.
> rdma_netdev is the one who belongs to both layers, ipoib and the low-level.

IPOIB rdma_netdev's can be casted to ipoib_rdma_netdev, so it is where
ipoib specific cross-layer stuff should live

Jason
