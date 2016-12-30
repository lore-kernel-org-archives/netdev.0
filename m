From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: fix branch prediction in sh_eth_interrupt()
Date: Thu, 29 Dec 2016 22:16:22 -0500 (EST)
Message-ID: <20161229.221622.1861506744608931336.davem@davemloft.net>
References: <2810883.6xQhqSTVDe@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        ben.hutchings@codethink.co.uk
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2810883.6xQhqSTVDe@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 30 Dec 2016 00:07:38 +0300

> IIUC, likely()/unlikely() should apply to the whole *if* statement's
> expression, not a part of it  -- fix such expression in  sh_eth_interrupt()
> accordingly...
> 
> Fixes: 283e38db65e7 ("sh_eth: Fix serialisation of interrupt disable with interrupt & NAPI handlers")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against DaveM's 'net-next.git' repo; I'm not sure if it should
> be  targeted to the 'net.git' repo instead...

I decided to apply this to 'net', thanks.
