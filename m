From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: use correct req pointer in tcp_move_syn()
 calls
Date: Thu, 05 Nov 2015 15:58:17 -0500 (EST)
Message-ID: <20151105.155817.1711854298064825702.davem@davemloft.net>
References: <1446750433.4184.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446755819.4184.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446756619.4184.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycai@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbbKEU6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 15:58:19 -0500
In-Reply-To: <1446756619.4184.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Nov 2015 12:50:19 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> I mistakenly took wrong request sock pointer when calling tcp_move_syn()
> 
> @req_unhash is either a copy of @req, or a NULL value for
> FastOpen connexions (as we do not expect to unhash the temporary
> request sock from ehash table)
> 
> Fixes: 805c4bc05705 ("tcp: fix req->saved_syn race")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks for correcting this so quickly.
