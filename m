From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: macb: fix build warning
Date: Mon, 25 Jan 2016 10:52:27 -0800 (PST)
Message-ID: <20160125.105227.682058667144890592.davem@davemloft.net>
References: <1453702389-601-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453702389-601-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Mon, 25 Jan 2016 11:43:09 +0530

> We are getting build warning about:
> macb.c:2889:13: warning: 'tx_clk' may be used uninitialized in this function
> macb.c:2888:11: warning: 'hclk' may be used uninitialized in this function
> 
> In reality they are not used uninitialized as clk_init() will initialize
> them, this patch will just silence the warning.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Applied.
