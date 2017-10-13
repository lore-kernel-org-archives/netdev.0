From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: Consolidate clock handling
Date: Thu, 12 Oct 2017 23:01:14 -0700 (PDT)
Message-ID: <20171012.230114.1901066128868227139.davem@davemloft.net>
References: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, horms+renesas@verge.net.au,
        niklas.soderlund+renesas@ragnatech.se, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Thu, 12 Oct 2017 10:24:53 +0200

> The module clock is used for two purposes:
>   - Wake-on-LAN (WoL), which is optional,
>   - gPTP Timer Increment (GTI) configuration, which is mandatory.
> 
> As the clock is needed for GTI configuration anyway, WoL is always
> available.  Hence remove duplication and repeated obtaining of the clock
> by making GTI use the stored clock for WoL use.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied.
