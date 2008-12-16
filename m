From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: kernel panics with net_rx_action on kernels >2.6.26
Date: Tue, 16 Dec 2008 15:42:37 -0800 (PST)
Message-ID: <20081216.154237.263705877.davem@davemloft.net>
References: <20081215133521.GA6697@ff.dom.local>
	<20081216.012247.267028680.davem@davemloft.net>
	<20081216140651.GA6537@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, alexander.huemer@sbg.ac.at,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20081216140651.GA6537@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 16 Dec 2008 14:06:51 +0000

> drivers/net: starfire: Fix napi ->poll() weight handling
> 
> starfire napi ->poll() handler can return work == weight after calling
> netif_rx_complete() (if there is no more work). It is illegal and this
> patch fixes it.
> 
> Reported-by: Alexander Huemer <alexander.huemer@sbg.ac.at>
> Tested-by: Alexander Huemer <alexander.huemer@sbg.ac.at>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks everyone.
