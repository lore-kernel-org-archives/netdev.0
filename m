From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix rx-usecs interrupt pacing
 consistency
Date: Fri, 03 Jun 2016 19:35:34 -0400 (EDT)
Message-ID: <20160603.193534.1267260598418078664.davem@davemloft.net>
References: <1464873292-17011-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464873292-17011-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Thu,  2 Jun 2016 16:14:52 +0300

> The rx-usecs shouldn't be changed while interface down/up.
> Currently, for instance, if it's set to 100us, after interface
> down/up it's 500us. It's a hidden bug that can lead to lavish
> interrupt pacing time increasing while "down/up" up to max value.
> 
> Steps to reproduce:
> - set rx-usecs to be 100us
> - down/up interface
> - read new unexpected rx-usecs
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
