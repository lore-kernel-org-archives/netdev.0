From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: use netdev_rss_key_fill() helper
Date: Sun, 23 Nov 2014 21:02:14 -0500 (EST)
Message-ID: <20141123.210214.47886740287720431.davem@davemloft.net>
References: <1416774461.17888.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, _govind@gmx.com, netdev@vger.kernel.org,
	ssujith@cisco.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbaKXCCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 21:02:16 -0500
In-Reply-To: <1416774461.17888.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 23 Nov 2014 12:27:41 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Use of well known RSS key might increase attack surface.
> 
> Switch to a random one, using generic helper so that all
> ports share a common key.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
