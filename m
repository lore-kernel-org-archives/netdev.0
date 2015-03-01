From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: bcmgenet: fix throughtput regression
Date: Sun, 01 Mar 2015 00:30:07 -0500 (EST)
Message-ID: <20150301.003007.247806713909808067.davem@davemloft.net>
References: <1425091706-5811-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, pgynther@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jaedon.shin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425091706-5811-1-git-send-email-jaedon.shin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaedon Shin <jaedon.shin@gmail.com>
Date: Sat, 28 Feb 2015 11:48:26 +0900

> This patch adds bcmgenet_tx_poll for the tx_rings. This can reduce the
> interrupt load and send xmit in network stack on time. This also
> separated for the completion of tx_ring16 from bcmgenet_poll.
> 
> The bcmgenet_tx_reclaim of tx_ring[{0,1,2,3}] operative by an interrupt
> is to be not more than a certain number TxBDs. It is caused by too
> slowly reclaiming the transmitted skb. Therefore, performance
> degradation of xmit after 605ad7f ("tcp: refine TSO autosizing").
> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
