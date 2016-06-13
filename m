From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: use destroy ctlr to destroy
 channels
Date: Sun, 12 Jun 2016 22:01:35 -0400 (EDT)
Message-ID: <20160612.220135.2211381636490955858.davem@davemloft.net>
References: <1465596714-26697-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	mugunthanvnm@ti.com, grygorii.strashko@ti.com,
	netdev@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465596714-26697-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Sat, 11 Jun 2016 01:11:54 +0300

> There is no reason to destroy channels that are destroyed while
> cpdma_ctlr destroy. In this case no need to remember how much
> channels where created and destroy them by one, as cpdma_ctlr
> destroys all of them.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
