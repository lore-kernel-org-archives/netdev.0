From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: ethernet: ti: cpsw: remove rx_descs
 property
Date: Fri, 10 Jun 2016 22:50:43 -0700 (PDT)
Message-ID: <20160610.225043.1035032413161700163.davem@davemloft.net>
References: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
	<1465307976-12235-2-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, bcousson@baylibre.com, tony@atomide.com,
	devicetree@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbcFKFup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 01:50:45 -0400
In-Reply-To: <1465307976-12235-2-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Tue,  7 Jun 2016 16:59:35 +0300

>  	if (!cpsw_common_res_usage_state(priv)) {
> +		int buf_num;
>  		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
>  

Please always order local variable declarations from longest to shortest
line.
