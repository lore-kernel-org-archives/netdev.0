From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net/phy: Add Vitesse 8641 phy ID"
Date: Sun, 20 Sep 2015 22:29:58 -0700 (PDT)
Message-ID: <20150920.222958.1980421261806526160.davem@davemloft.net>
References: <1442562150-19720-1-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Shaohui.Xie@freescale.com
To: haokexin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755695AbbIUFaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:30:00 -0400
In-Reply-To: <1442562150-19720-1-git-send-email-haokexin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <haokexin@gmail.com>
Date: Fri, 18 Sep 2015 15:42:30 +0800

> This reverts commit 1298267b548a78840bd4b3e030993ff8747ca5e6.
> 
> That commit claim that the Vitesse VSC8641 is compatible with Vitesse
> 82xx. But this is not true. It seems that all the registers used
> in Vitesse phy driver are not compatible between 8641 and 82xx.
> It does cause malfunction of the Ethernet on p1010rdb-pa board.
> So we definitely need a rework in order to support the 8641 phy
> in this driver.
> 
> Signed-off-by: Kevin Hao <haokexin@gmail.com>

Applied.
