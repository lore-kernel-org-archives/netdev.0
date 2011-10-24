From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: fix cfcnfg_add_phy_layer() leaks
Date: Mon, 24 Oct 2011 18:36:23 -0400 (EDT)
Message-ID: <20111024.183623.551713905402332500.davem@davemloft.net>
References: <alpine.LNX.2.00.1110242359160.19795@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sjur.brandeland@stericsson.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1110242359160.19795@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Tue, 25 Oct 2011 00:01:00 +0200 (CEST)

> There are two locations where we 'goto out' after having allocated
> memory for 'phyinfo' but have not yet assigned it to anything. At the
> 'out:' label we'll exit from the function and 'phyinfo' will go out of
> scope and thus we leak the memory we allocated.
> 
> This patch frees the memory before jumping to 'out:', thus fixing the
> leaks.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

The code in net-next looks a lot different, please see if the issue
still exists there and resubmit if so, thanks!
