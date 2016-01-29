From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: fix packet corruption with TSO and
 tiny unaligned packets.
Date: Thu, 28 Jan 2016 16:08:30 -0800 (PST)
Message-ID: <20160128.160830.991100889530042617.davem@davemloft.net>
References: <1453821155-27561-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, philipp@familie-kirchhofer.de
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453821155-27561-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Tue, 26 Jan 2016 16:12:35 +0100

> The code in txq_put_data() would use txq->tx_curr_desc to index the
> tso_hdrs/tso_hdrs_dma buffers, for less than 8 bytes unaligned
> fragments, which is already moved to the next descriptor at the
> beginning of the function.
> 
> If that fragment was the last of the the skb, the next skb would use
> that same space to place the ip headers, overwritting that small
> fragment data.
> 
> Fixes: 91986fd3d335 (net: mv643xx_eth: Ensure proper data alignment in TSO TX path)
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>

Applied.
