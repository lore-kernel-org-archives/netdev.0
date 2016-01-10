From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc-acm: fix NULL pointer reference
Date: Sat, 09 Jan 2016 21:01:09 -0500 (EST)
Message-ID: <20160109.210109.1470783311818213122.davem@davemloft.net>
References: <1452160860-2752-1-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galkin-vv@yandex.ru
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613AbcAJCBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 21:01:13 -0500
In-Reply-To: <1452160860-2752-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Thu,  7 Jan 2016 11:01:00 +0100

> The union descriptor must be checked. Its usage was conditional
> before the parser was introduced. This is important, because
> many RNDIS device, which also use the common parser, have
> bogus extra descriptors.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.com>
> Tested-by: Vasily Galkin <galkin-vv@yandex.ru>

Applied, thanks Oliver.
