From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH net-next v2] net: stmmac: fix NULL pointer
 dereference in stmmac_get_tx_hwtstamp
Date: Sun, 19 Jan 2014 20:03:52 -0800 (PST)
Message-ID: <20140119.200352.719528361166763885.davem@davemloft.net>
References: <1389973679-2755-1-git-send-email-damuzi000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: damuzi000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389973679-2755-1-git-send-email-damuzi000@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bruce Liu <damuzi000@gmail.com>
Date: Fri, 17 Jan 2014 23:47:59 +0800

> When timestamping is enabled, stmmac_tx_clean will call
> stmmac_get_tx_hwtstamp to get tx TS.
> But the skb can be NULL because the last of its tx_skbuff is NULL
> if this packet frame is filled in more than one descriptors.
> 
> To fix the issue, change the code:
> - Store TX skb to the tx_skbuff[] of frame's last segment.
> - Check skb is not NULL in stmmac_get_tx_hwtstamp.
> 
> Signed-off-by: Bruce Liu <damuzi000@gmail.com>

Looks a lot better, applied, thanks.
