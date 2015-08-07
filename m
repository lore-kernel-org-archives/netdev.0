From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: dwmac-ipq806x: fix static checker warning
Date: Fri, 07 Aug 2015 00:12:32 -0700 (PDT)
Message-ID: <20150807.001232.883736987030332955.davem@davemloft.net>
References: <1438734302-22930-1-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mathieu@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438734302-22930-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mathieu Olivari <mathieu@codeaurora.org>
Date: Tue,  4 Aug 2015 17:25:02 -0700

> The patch b1c17215d718: "stmmac: add ipq806x glue layer", leads to the
> following static checker warning:
> 
> .../stmmac/dwmac-ipq806x.c:314 ipq806x_gmac_probe()
> warn: double left shift '1 << (1 << gmac->id)'
> 
> The NSS_COMMON_CLK_SRC_CTRL_OFFSET macro is used once as an offset, and
> once as a mask, which is a bug indeed. We'll fix it by defining the
> offset as the real offset value and computing the mask from it when
> required.
> 
> Tested on IPQ806x ref designs AP148 & DB149.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>

Applied.
