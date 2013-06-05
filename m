From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: add missing semicolon
Date: Tue, 04 Jun 2013 17:19:12 -0700 (PDT)
Message-ID: <20130604.171912.471267812978152333.davem@davemloft.net>
References: <4063428.ukZe9BdPSb@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab3FEATN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:19:13 -0400
In-Reply-To: <4063428.ukZe9BdPSb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 03 Jun 2013 15:11:24 +0200

> 76723bca28 "net: mv643xx_eth: add DT parsing support" added a
> dummy mv643xx_eth_shared_of_probe() fallback function with a
> typo.
> 
> This adds the missing semicolon so we can build without CONFIG_OF
> again, and changes both dummy functions to the more conventional
> "static inline" syntax, which can avoid potential problems with
> the empty macro.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
