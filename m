From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] r8169: fix an if condition
Date: Mon, 22 Sep 2014 15:19:50 -0400 (EDT)
Message-ID: <20140922.151950.1466634293164677043.davem@davemloft.net>
References: <20140919104025.GA26391@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, hayeswang@realtek.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaIVTTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:19:52 -0400
In-Reply-To: <20140919104025.GA26391@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 19 Sep 2014 13:40:25 +0300

> There is an extra semi-colon so __rtl8169_set_features() is called every
> time.
> 
> Fixes: 929a031dfd62 ('r8169: adjust __rtl8169_set_features')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Dan, this bug exists in 'net' so that is what you should have
targetted this tree at.

Applied, thanks.
