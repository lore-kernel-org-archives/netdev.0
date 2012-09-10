From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 6/7] bnx2x: fix self-test
Date: Mon, 10 Sep 2012 16:38:02 -0400 (EDT)
Message-ID: <20120910.163802.1028442535606094485.davem@davemloft.net>
References: <1347292135-30250-1-git-send-email-yuvalmin@broadcom.com>
	<1347292135-30250-7-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152Ab2IJUiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 16:38:04 -0400
In-Reply-To: <1347292135-30250-7-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 10 Sep 2012 18:48:54 +0300

> From: Dmitry Kravkov <dmitry@broadcom.com>
> 
> Under traffic, there are several registers that when read (e.g., via 
> 'ethtool -t') may cause the chip to stall.
> This patch corrects the registers read in such flows.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

You cannot change the size of layout of the register dump without
updating the ethtool register dump version advertised by the
driver.

You're currently the register dump version to zero.
