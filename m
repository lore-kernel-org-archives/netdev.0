From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: tile: Remove unnecessary memset of netdev
 private data
Date: Fri, 30 May 2014 17:06:47 -0700 (PDT)
Message-ID: <20140530.170647.451034663144296827.davem@davemloft.net>
References: <1401192231-26203-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaEaAGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:06:48 -0400
In-Reply-To: <1401192231-26203-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 27 May 2014 14:03:51 +0200

> The memory for private data is allocated using kzalloc/vzalloc in
> alloc_netdev_mqs, thus there is no need to zero it again in the driver.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
