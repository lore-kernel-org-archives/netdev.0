From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: nb8800: fix error handling of
 nb8800_probe()
Date: Wed, 20 Jul 2016 14:48:08 -0700 (PDT)
Message-ID: <20160720.144808.2207590028125455831.davem@davemloft.net>
References: <1468927990-3041-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, mans@mansr.com, tremyfr@gmail.com,
	arnd@arndb.de, sf84@laposte.net, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430AbcGTVsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 17:48:19 -0400
In-Reply-To: <1468927990-3041-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj_lk@163.com>
Date: Tue, 19 Jul 2016 11:33:10 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In ops->reset() error handling case, clk_disable_unprepare() is missed
> before return from this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
