From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: davinci: Fix build breakage
Date: Mon, 21 Jan 2013 13:13:14 -0500 (EST)
Message-ID: <20130121.131314.1276887267486833907.davem@davemloft.net>
References: <1358761119-25846-1-git-send-email-thierry.reding@avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: thierry.reding@avionic-design.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358761119-25846-1-git-send-email-thierry.reding@avionic-design.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@avionic-design.de>
Date: Mon, 21 Jan 2013 10:38:39 +0100

> The correct name of the transmit DMA channel field in struct emac_priv
> is txchan, not txch.
> 
> Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>

Nothing is more irritating than someone not saying what tree their
patch is targetted for.  My time is not well used by playing a
guessing game about where a patch is supposed to go.

After some futzing around I was able to determine that this patch
is needed for net-next only, but please make a specific mention of
this next time.

Applied, thanks.
