From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ethernet: ti: cpsw: fix cpsw assignment in
 resume
Date: Tue, 14 Feb 2017 14:54:48 -0500 (EST)
Message-ID: <20170214.145448.42455339055289365.davem@davemloft.net>
References: <1487076135-4798-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487076135-4798-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Tue, 14 Feb 2017 14:42:15 +0200

> There is a copy-paste error, which hides breaking of resume
> for CPSW driver: there was replaced netdev_priv() to ndev_to_cpsw(ndev)
> in suspend, but left it unchanged in resume.
> 
> Fixes: 606f39939595a4d4540406bfc11f265b2036af6d
> (ti: cpsw: move platform data and slaves info to cpsw_common)
> 
> Reported-by: Alexey Starikovskiy <AStarikovskiy@topcon.com>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied and queued up for -stable, thanks.
