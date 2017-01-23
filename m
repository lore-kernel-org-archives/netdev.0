From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: xilinx: constify net_device_ops structure
Date: Mon, 23 Jan 2017 16:00:50 -0500 (EST)
Message-ID: <20170123.160050.47891500917690442.davem@davemloft.net>
References: <1484981938-29829-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484981938-29829-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Sat, 21 Jan 2017 12:28:58 +0530

> Declare net_device_ops structure as const as it is only stored in
> the netdev_ops field of a net_device structure. This field is of type
> const, so net_device_ops structures having same properties can be made
> const too.
> Done using Coccinelle:
 ...
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
