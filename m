From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: phy: micrel: Staticize
 ksz8873mll_read_status()
Date: Wed, 07 Aug 2013 16:59:50 -0700 (PDT)
Message-ID: <20130807.165950.1638875875927373328.davem@davemloft.net>
References: <000101ce927f$15413560$3fc3a020$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hector.palacios@digi.com,
	david.choi@micrel.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933256Ab3HGXyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 19:54:35 -0400
In-Reply-To: <000101ce927f$15413560$3fc3a020$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 06 Aug 2013 17:29:35 +0900

> ksz8873mll_read_status() is used only in this file.
> Fix the following sparse warning:
> 
> drivers/net/phy/micrel.c:147:5: warning: symbol 'ksz8873mll_read_status' was not declared. Should it be static?
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
