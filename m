From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: eth: altera: Change reset_mac failure message
 masks from err to dbg
Date: Thu, 19 Feb 2015 15:24:10 -0500 (EST)
Message-ID: <20150219.152410.394447672952089316.davem@davemloft.net>
References: <1423759665-5062-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org, vbridger@altera.com
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423759665-5062-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Thu, 12 Feb 2015 10:47:45 -0600

> This debug output is not really an error message since mac reset can fail
> if the phy clocks are gated, specifically when the phy has been placed in
> a powered down or isolation mode. The netdev output masks were changed from
> err to dbg, and comments added in the code.
> 
> Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>

Also applied to net-next, thanks.
