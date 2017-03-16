From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: mvneta: support suspend and resume
Date: Thu, 16 Mar 2017 10:20:51 -0700 (PDT)
Message-ID: <20170316.102051.849511497560035279.davem@davemloft.net>
References: <1489652548-45156-1-git-send-email-jiel@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jszhang@marvell.com
To: jiel@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489652548-45156-1-git-send-email-jiel@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jane Li <jiel@marvell.com>
Date: Thu, 16 Mar 2017 16:22:28 +0800

> Add basic support for handling suspend and resume.
> 
> Signed-off-by: Jane Li <jiel@marvell.com>
> Reviewed-by: Jisheng Zhang <jszhang@marvell.com>
> ---
> Since v3:
> - check clk_bus before enabling it during resume
> 
> Since v2:
> - use SIMPLE_DEV_PM_OPS instead of SET_LATE_SYSTEM_SLEEP_PM_OPS
> 
> Since v1:
> - add mvneta_conf_mbus_windows() and mvneta_bm_port_init() in mvneta_resume()

Applied to net-next.
