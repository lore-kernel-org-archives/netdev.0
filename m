From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: RDS: TCP: Delete an error message for a failed memory allocation
 in rds_tcp_init_net()
Date: Mon, 22 May 2017 16:32:58 +0200
Message-ID: <1e1a5d08-34a7-1b88-80ac-c650c4ae76cf@users.sourceforge.net>
References: <44b46c51-3665-5f14-dd3b-6e6f230258a7@users.sourceforge.net>
 <5d523cf8-1540-e704-2301-a5e0205cb536@users.sourceforge.net>
 <20170522142651.GA29434@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        LKML <linux-kernel@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        rds-devel@oss.oracle.com, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522142651.GA29434@oracle.com>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Omit an extra message for a memory allocation failure in this function.
> 
> The change itself is harmless,  but I'm curious about the "extra"
> part: "extra" from what? If this happens, hopefully this will be logged
> somewhere? Note that this type of (infrequent) logging noise is useful
> in some cases, e.g., with 8ce675ff, when one is trying to do the
> post-mortem of where things first went wrong.

Do you find information from a Linux allocation failure report sufficient
for such an use case?

Regards,
Markus
