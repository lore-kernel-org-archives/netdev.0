From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: phy: Fix return value check in
 xgmiitorgmii_probe()
Date: Mon, 15 Aug 2016 16:34:43 -0700 (PDT)
Message-ID: <20160815.163443.1332884548426044511.davem@davemloft.net>
References: <1471300497-15066-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, appana.durga.rao@xilinx.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbcHOXer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 19:34:47 -0400
In-Reply-To: <1471300497-15066-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 15 Aug 2016 22:34:57 +0000

> In case of error, the function of_parse_phandle() returns NULL
> pointer not ERR_PTR(). The IS_ERR() test in the return value check
> should be replaced with NULL test.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
