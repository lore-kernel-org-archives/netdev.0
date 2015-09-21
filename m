From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: fix races in reqsk_queue_hash_req()
Date: Mon, 21 Sep 2015 16:32:50 -0700 (PDT)
Message-ID: <20150921.163250.2246841376620160899.davem@davemloft.net>
References: <1442681284.29850.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycai@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756925AbbIUXcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:32:51 -0400
In-Reply-To: <1442681284.29850.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 Sep 2015 09:48:04 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Before allowing lockless LISTEN processing, we need to make
> sure to arm the SYN_RECV timer before the req socket is visible
> in hash tables.
> 
> Also, req->rsk_hash should be written before we set rsk_refcnt
> to a non zero value.
> 
> Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ying Cai <ycai@google.com>

Applied and queued up for -stable.
