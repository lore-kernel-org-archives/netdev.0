From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] r8152: constify ethtool_ops structures
Date: Wed, 31 Aug 2016 20:46:23 -0700 (PDT)
Message-ID: <20160831.204623.356903218954771686.davem@davemloft.net>
References: <1472682083-5219-1-git-send-email-Julia.Lawall@lip6.fr>
        <1472682083-5219-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472682083-5219-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Thu,  1 Sep 2016 00:21:22 +0200

> Check for ethtool_ops structures that are only stored in the ethtool_ops
> field of a net_device structure or passed as the second argument to
> netdev_set_default_ethtool_ops.  These contexts are declared const, so
> ethtool_ops structures that have these properties can be declared as const
> also.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
