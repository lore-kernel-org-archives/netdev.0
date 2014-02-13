From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: axienet: Fix compilation warnings
Date: Thu, 13 Feb 2014 18:08:06 -0500 (EST)
Message-ID: <20140213.180806.1440448228867354144.davem@davemloft.net>
References: <cover.1392275432.git.michal.simek@xilinx.com>
	<cover.1392275432.git.michal.simek@xilinx.com>
	<9be652e995e74663de1df69e6ea101225cb670a2.1392275432.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthokal@xilinx.com, monstr@monstr.eu,
	anirudh@xilinx.com, John.Linn@xilinx.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9be652e995e74663de1df69e6ea101225cb670a2.1392275432.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Thu, 13 Feb 2014 08:10:43 +0100

> Warning log:
> xilinx_axienet_main.c: In function 'axienet_start_xmit_done':
> xilinx_axienet_main.c:617:16: warning: operation on 'lp->tx_bd_ci' may be undefined [-Wsequence-point]
> xilinx_axienet_main.c: In function 'axienet_start_xmit':
> xilinx_axienet_main.c:703:18: warning: operation on 'lp->tx_bd_tail' may be undefined [-Wsequence-point]
> xilinx_axienet_main.c:719:17: warning: operation on 'lp->tx_bd_tail' may be undefined [-Wsequence-point]
> xilinx_axienet_main.c: In function 'axienet_recv':
> xilinx_axienet_main.c:792:16: warning: operation on 'lp->rx_bd_ci' may be undefined [-Wsequence-point]
> xilinx_axienet_main.c: In function 'axienet_of_probe':
> xilinx_axienet_main.c:1501:21: warning: unused variable 'rc' [-Wunused-variable]
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied.
