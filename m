From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dnet: fix dnet_poll()
Date: Sun, 11 Jan 2015 21:45:30 -0500 (EST)
Message-ID: <20150111.214530.1743863715448013581.davem@davemloft.net>
References: <1421002952.5947.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbbALCpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 21:45:32 -0500
In-Reply-To: <1421002952.5947.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 11 Jan 2015 11:02:32 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> A NAPI poll() handler is supposed to return exactly the budget when/if
> napi_complete() has not been called.
> 
> It is also supposed to return number of frames that were received, so
> that netdev_budget can have a meaning.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
