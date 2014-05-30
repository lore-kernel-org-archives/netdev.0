From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: tso: Export symbols for modular build
Date: Fri, 30 May 2014 15:52:20 -0700 (PDT)
Message-ID: <20140530.155220.733047502973295337.davem@davemloft.net>
References: <1401096166-5409-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ezequiel.garcia@free-electrons.com
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964906AbaE3WwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:52:21 -0400
In-Reply-To: <1401096166-5409-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon, 26 May 2014 14:52:46 +0530

> Export the symbols to fix the below errors when built as modules:
> ERROR: "tso_build_data" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
> ERROR: "tso_build_hdr" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
> ERROR: "tso_start" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
> ERROR: "tso_count_descs" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
> ERROR: "tso_build_data" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "tso_build_hdr" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "tso_start" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "tso_count_descs" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied, thank you.
