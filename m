From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bql: fix CONFIG_XPS=n build
Date: Mon, 05 Dec 2011 18:46:38 -0500 (EST)
Message-ID: <20111205.184638.2243771967406541767.davem@davemloft.net>
References: <1323038280.14707.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932481Ab1LEXql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 18:46:41 -0500
In-Reply-To: <1323038280.14707.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Dec 2011 23:38:00 +0100

> netdev_queue_release() should be called even if CONFIG_XPS=n
> to properly release device reference.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
