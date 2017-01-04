From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: enable RX descriptor word 0 shift on SH7734
Date: Wed, 04 Jan 2017 16:12:37 -0500 (EST)
Message-ID: <20170104.161237.114609536667255148.davem@davemloft.net>
References: <1893574.OD9Leu8Ck8@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1893574.OD9Leu8Ck8@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 04 Jan 2017 23:10:23 +0300

> The RX descriptor word 0 on SH7734 has the RFS[9:0] field in bits 16-25
> (bits  0-15 usually used for that are occupied by the packet checksum).
> Thus  we need to set the 'shift_rd0'  field in the SH7734 SoC data...
> 
> Fixes: f0e81fecd4f8 ("net: sh_eth: Add support SH7734")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thank you.
