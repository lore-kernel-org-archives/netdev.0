From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] b44: call netif_napi_del()
Date: Sun, 07 Jun 2015 19:45:46 -0700 (PDT)
Message-ID: <20150607.194546.390123172004131981.davem@davemloft.net>
References: <1433679108-20923-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbbFHCpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 22:45:47 -0400
In-Reply-To: <1433679108-20923-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sun,  7 Jun 2015 14:11:48 +0200

> When the driver gets unregistered a call to netif_napi_del() was
> missing, this all was also missing in the error paths of
> b44_init_one().
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
> 
> changes since v1:
>  * netif_napi_del() is now also called in b44_init_one() error paths.

Applied, thank you.
