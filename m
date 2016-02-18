From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] route: check and remove route cache when we get
 route
Date: Thu, 18 Feb 2016 11:32:17 -0500 (EST)
Message-ID: <20160218.113217.1484051937122168598.davem@davemloft.net>
References: <e190b1f6eb762c5770faef080ef6080a6dbdedfb.1455801679.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425080AbcBRQcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 11:32:19 -0500
In-Reply-To: <e190b1f6eb762c5770faef080ef6080a6dbdedfb.1455801679.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 18 Feb 2016 21:21:19 +0800

> Since the gc of ipv4 route was removed, the route cached would has
> no chance to be removed, and even it has been timeout, it still could
> be used, cause no code to check it's expires.
> 
> Fix this issue by checking  and removing route cache when we get route.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
