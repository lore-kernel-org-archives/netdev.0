From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: return NET_XMIT_DROP if
 skb_padto failed
Date: Sat, 11 Feb 2017 21:27:16 -0500 (EST)
Message-ID: <20170211.212716.1588683658880411414.davem@davemloft.net>
References: <1486777797-28143-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486777797-28143-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Sat, 11 Feb 2017 03:49:57 +0200

> If skb_padto failed the skb has been dropped already, so it was
> consumed, but it doesn't mean it was sent, thus no need to update
> queue tx time, etc. So, return NET_XMIT_DROP as more appropriate.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
