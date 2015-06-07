From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: call netif_napi_del()
Date: Sun, 07 Jun 2015 00:09:43 -0700 (PDT)
Message-ID: <20150607.000943.2029769037357916514.davem@davemloft.net>
References: <1433625766-12319-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbFGHJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 03:09:44 -0400
In-Reply-To: <1433625766-12319-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat,  6 Jun 2015 23:22:46 +0200

> When the driver gets unregistered a call to netif_napi_del() was
> missing.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

This patch is incomplete.

All of that failure paths in b44_init_one() after the netif_napi_add()
call have the same exact bug.

Please fix those too and resubmit.

Thanks.
