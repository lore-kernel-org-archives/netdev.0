From: David Miller <davem@davemloft.net>
Subject: Re: [net patch 0/2] bnx2x: Correct bnx2x operation with netpoll
Date: Thu, 30 Aug 2012 13:37:48 -0400 (EDT)
Message-ID: <20120830.133748.276745804577135815.davem@davemloft.net>
References: <1346073980-30901-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab2H3Rhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:37:50 -0400
In-Reply-To: <1346073980-30901-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Mon, 27 Aug 2012 16:26:18 +0300

> Hi Dave,
> This patch series corrects bnx2x operation with netpoll:
> The first patch is to move the netif_napi_add to the open call to avoid napi
> objects that are added but may not be later enabled.
> The second patch corrects the poll_bnx2x function itself to also work with
> MSI-X.
> 
> Please consider applying this patch series to net.

Applied.
