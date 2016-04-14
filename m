From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: make ravb_ptp_interrupt() *void*
Date: Thu, 14 Apr 2016 00:48:44 -0400 (EDT)
Message-ID: <20160414.004844.306071511236659725.davem@davemloft.net>
References: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
	<6123492.pMMRNT1FnA@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <6123492.pMMRNT1FnA@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 10 Apr 2016 23:55:15 +0300

> When we have the ISS.CGIS bit set, we already know that gPTP interrupt has
> happened, so an extra GIS register check at the end of ravb_ptp_interrupt()
> seems superfluous.  We can model the gPTP interrupt  handler like all other
> dedicated interrupt handlers in the driver and make it *void*.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
