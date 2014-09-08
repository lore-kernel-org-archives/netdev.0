From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: systemport and bcmgenet OOM fixes
Date: Mon, 08 Sep 2014 16:03:33 -0700 (PDT)
Message-ID: <20140908.160333.1451721989186204903.davem@davemloft.net>
References: <1410201472-3764-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbaIHXDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 19:03:35 -0400
In-Reply-To: <1410201472-3764-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  8 Sep 2014 11:37:50 -0700

> These two patches fix similar Out of Memory code paths in the SYSTEMPORT and
> GENET drivers. Under high memory pressure, we could produce an OOPS by
> passing a NULL pointer to dma_unmap_single().

Series applied, thanks Florian.
