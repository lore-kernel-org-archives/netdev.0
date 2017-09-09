From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] phy: mvebu-cp110: checking for NULL instead of
 IS_ERR()
Date: Fri, 08 Sep 2017 21:09:05 -0700 (PDT)
Message-ID: <20170908.210905.626281012369795940.davem@davemloft.net>
References: <20170908103137.zck6bw66sge4fhua@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kishon@ti.com, antoine.tenart@free-electrons.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908103137.zck6bw66sge4fhua@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 8 Sep 2017 13:31:37 +0300

> devm_ioremap_resource() never returns NULL, it only returns error
> pointers so this test needs to be changed.
> 
> Fixes: d0438bd6aa09 ("phy: add the mvebu cp110 comphy driver")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This driver apparently is going through the net tree, but netdev isn't
> listed as handling it in MAINTAINERS.  Kishon, do you know what's up
> with that?

Yeah let's sort this out before I apply this fix to my tree.
