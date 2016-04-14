From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: ethernet: renesas: ravb_main: test clock
 rate to avoid division by 0
Date: Wed, 13 Apr 2016 22:43:41 -0400 (EDT)
Message-ID: <20160413.224341.183773545765700897.davem@davemloft.net>
References: <1460114922-4148-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: wsa@the-dreams.de
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1460114922-4148-1-git-send-email-wsa@the-dreams.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa@the-dreams.de>
Date: Fri,  8 Apr 2016 13:28:42 +0200

> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
> 
> The clk API may return 0 on clk_get_rate, so we should check the result before
> using it as a divisor.
> 
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
