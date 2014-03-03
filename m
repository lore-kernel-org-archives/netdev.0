From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] b44: always set duplex mode why phy changes
Date: Sun, 02 Mar 2014 19:06:00 -0500 (EST)
Message-ID: <20140302.190600.744394474350912563.davem@davemloft.net>
References: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
	<1393777774-7400-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479AbaCCAGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 19:06:01 -0500
In-Reply-To: <1393777774-7400-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sun,  2 Mar 2014 17:29:34 +0100

> Without this patch b44_check_phy() was called when the phy called the
> adjust callback. This method only change the mac duplex mode when the
> carrier was off. When the phy changed the duplex mode after the carrier
> was on the mac was not changed. This happened when an external phy was
> used.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied.
