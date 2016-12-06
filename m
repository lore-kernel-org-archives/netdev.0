From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix early budget split
Date: Tue, 06 Dec 2016 11:37:35 -0500 (EST)
Message-ID: <20161206.113735.76573422393058311.davem@davemloft.net>
References: <1480988700-17046-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480988700-17046-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Tue,  6 Dec 2016 03:45:00 +0200

> The budget split function requires the phy speed to be known.
> While ndo open a phy speed identification is postponed till the
> moment link is up. Hence, move it to appropriate callback, when link
> is up.
> 
> Reported-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Fixes: 8feb0a196507 ("net: ethernet: ti: cpsw: split tx budget according between channels")
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
