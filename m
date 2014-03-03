From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ieee802154: fix at86rf212_set_txpower() exit
 path
Date: Mon, 03 Mar 2014 15:40:48 -0500 (EST)
Message-ID: <20140303.154048.1230180202774511095.davem@davemloft.net>
References: <1393714476-21515-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590AbaCCUku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:40:50 -0500
In-Reply-To: <1393714476-21515-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sat,  1 Mar 2014 15:54:36 -0700

> The commit 9b2777d6089bc ("ieee802154: add TX power control to
> wpan_phy") introduced the new function at86rf212_set_txpower() with
> the questionable check of the return of __at86rf230_write() in the
> exit path:
> 
> 1) Both at86rf212_set_txpower() and __at86rf230_write() have the
>    same return type.
> 
> 2) Whatever __at86rf230_write() returns becomes the return value of
>    at86rf212_set_txpower().
> 
> Thus, fix the exit path by getting rid of that check entirely.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied, thank you.
