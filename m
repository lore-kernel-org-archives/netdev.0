From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ethernet: renesas: sh_eth: add POST registers
 for rz
Date: Sat, 10 Sep 2016 21:12:05 -0700 (PDT)
Message-ID: <20160910.211205.2263493847383395899.davem@davemloft.net>
References: <20160907185709.24150-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, horms+renesas@verge.net.au,
        geert+renesas@glider.be, daniel@0x0f.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: chris.brandt@renesas.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160907185709.24150-1-chris.brandt@renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Brandt <chris.brandt@renesas.com>
Date: Wed,  7 Sep 2016 14:57:09 -0400

> Due to a mistake in the hardware manual, the FWSLC and POST1-4 registers
> were not documented and left out of the driver for RZ/A making the CAM
> feature non-operational.
> Additionally, when the offset values for POST1-4 are left blank, the driver
> attempts to set them using an offset of 0xFFFF which can cause a memory
> corruption or panic.
> 
> This patch fixes the panic and properly enables CAM.
> 
> Reported-by: Daniel Palmer <daniel@0x0f.com>
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>

Applied, thanks.
