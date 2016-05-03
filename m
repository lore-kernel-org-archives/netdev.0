From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pxa168_eth: fix mdiobus_scan() error check
Date: Tue, 03 May 2016 15:03:50 -0400 (EDT)
Message-ID: <20160503.150350.37387977385971030.davem@davemloft.net>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
	<6024241.YxM8l6DPJo@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933291AbcECTD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 15:03:57 -0400
In-Reply-To: <6024241.YxM8l6DPJo@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 30 Apr 2016 23:35:11 +0300

> Since mdiobus_scan() returns either an error code or NULL on error, the
> driver should check  for both,  not only for NULL, otherwise a crash is
> imminent...
> 
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
