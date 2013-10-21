From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] davinci_emac.c: Fix IFF_ALLMULTI setup
Date: Mon, 21 Oct 2013 18:57:59 -0400 (EDT)
Message-ID: <20131021.185759.2298688785062999792.davem@davemloft.net>
References: <5265640C.4070201@cogentembedded.com>
	<1382377504-24688-1-git-send-email-mceier+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, prabhakar.csengg@gmail.com,
	jg1.han@samsung.com, jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mceier+kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382377504-24688-1-git-send-email-mceier+kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Ceier <mceier+kernel@gmail.com>
Date: Mon, 21 Oct 2013 19:45:04 +0200

> When IFF_ALLMULTI flag is set on interface and IFF_PROMISC isn't,
> emac_dev_mcast_set should only enable RX of multicasts and reset
> MACHASH registers.
> 
> It does this, but afterwards it either sets up multicast MACs
> filtering or disables RX of multicasts and resets MACHASH registers
> again, rendering IFF_ALLMULTI flag useless.
> 
> This patch fixes emac_dev_mcast_set, so that multicast MACs filtering and
> disabling of RX of multicasts are skipped when IFF_ALLMULTI flag is set.
> 
> Tested with kernel 2.6.37.
> 
> Signed-off-by: Mariusz Ceier <mceier+kernel@gmail.com>

Applied and queued up for -stable, thanks.
