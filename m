From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: stmmac: free an skb first when there are no
 longer any descriptors using it
Date: Tue, 20 Jun 2017 15:41:23 -0400 (EDT)
Message-ID: <20170620.154123.561428545995150660.davem@davemloft.net>
References: <20170620123241.5677-1-niklas.cassel@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620123241.5677-1-niklas.cassel@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Tue, 20 Jun 2017 14:32:41 +0200

> When having the skb pointer in the first descriptor, stmmac_tx_clean
> can get called at a moment where the IP has only cleared the own bit
> of the first descriptor, thus freeing the skb, even though there can
> be several descriptors whose buffers point into the same skb.
> 
> By simply moving the skb pointer from the first descriptor to the last
> descriptor, a skb will get freed only when the IP has cleared the
> own bit of all the descriptors that are using that skb.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied and queued up for -stable, thanks.
