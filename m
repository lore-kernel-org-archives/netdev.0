From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: avoid unused function warnings
Date: Tue, 30 Aug 2016 23:32:38 -0700 (PDT)
Message-ID: <20160830.233238.1711742937489908366.davem@davemloft.net>
References: <20160826153108.680850-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, ykaneko0929@gmail.com,
        kazuya.mizuguchi.ks@renesas.com, horms+renesas@verge.net.au,
        masaru.nagai.vx@renesas.com, niklas.soderlund+renesas@ragnatech.se,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160826153108.680850-1-arnd@arndb.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 26 Aug 2016 17:30:29 +0200

> When CONFIG_PM_SLEEP is disabled, we get a couple of harmless warnings:
> 
> drivers/net/ethernet/renesas/ravb_main.c:2117:12: error: 'ravb_resume' defined but not used [-Werror=unused-function]
> drivers/net/ethernet/renesas/ravb_main.c:2104:12: error: 'ravb_suspend' defined but not used [-Werror=unused-function]
> 
> The simplest solution here is to replace the #ifdef with __maybe_unused
> annotations, which lets the compiler do the right thing by itself.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 0184165b2f42 ("ravb: add sleep PM suspend/resume support")

Applied, thanks.
