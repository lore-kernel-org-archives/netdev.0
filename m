From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ethernet: ti: davinci_cpdma: fix fixed prio
 cpdma ctlr configuration
Date: Sun, 13 Nov 2016 13:40:40 -0500 (EST)
Message-ID: <20161113.134040.2130627876291744441.davem@davemloft.net>
References: <1478871924-20985-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478871924-20985-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Fri, 11 Nov 2016 15:45:24 +0200

> The dma ctlr is reseted to 0 while cpdma soft reset, thus cpdma ctlr
> cannot be configured after cpdma is stopped. So restoring content
> of cpdma ctlr while off/on procedure is needed. The cpdma ctlr off/on
> procedure is present while interface down/up and while changing number
> of channels with ethtool. In order to not restore content in many
> places, move it to cpdma_ctlr_start().
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
