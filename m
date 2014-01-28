From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: initialize napi before registering device
Date: Mon, 27 Jan 2014 16:40:22 -0800 (PST)
Message-ID: <20140127.164022.1770189430751977967.davem@davemloft.net>
References: <20140125103454.GA2490@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlindner@marvell.com,
	stephen@networkplumber.org
To: stf_xl@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457AbaA1AkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 19:40:23 -0500
In-Reply-To: <20140125103454.GA2490@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <stf_xl@wp.pl>
Date: Sat, 25 Jan 2014 11:34:54 +0100

> There is race condition when call netif_napi_add() after
> register_netdevice(), as ->open() can be called without napi initialized
> and trigger BUG_ON() on napi_enable(), like on below messages:
...
> To fix the problem patch changes the order of initialization.
> 
> Bug report:
> https://bugzilla.kernel.org/show_bug.cgi?id=67151
> 
> Reported-and-tested-by: ebrahim.azarisooreh@gmail.com
> Signed-off-by: Stanislaw Gruszka <stf_xl@wp.pl>

Applied, thanks a lot.
