From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] 8139too: fix system hang when there is a tx
 timeout event.
Date: Mon, 01 Aug 2016 21:39:06 -0700 (PDT)
Message-ID: <20160801.213906.4719100211156764.davem@davemloft.net>
References: <1470030330-13277-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470030330-13277-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin <hau@realtek.com>
Date: Mon, 1 Aug 2016 13:45:30 +0800

> If tx timeout event occur, kernel will call rtl8139_tx_timeout_task() to reset
> hardware. But in this function, driver does not stop tx and rx function before
> reset hardware, that will cause system hang.
> 
> In this patch, add stop tx and rx function before reset hardware.
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

Applied, thanks.
