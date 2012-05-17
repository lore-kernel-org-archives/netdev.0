From: David Miller <davem@davemloft.net>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 15:55:03 -0400 (EDT)
Message-ID: <20120517.155503.2294382162578627387.davem@davemloft.net>
References: <20120517121800.GA18052@1wt.eu>
	<20120517150157.GA19274@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120Ab2EQTz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 15:55:26 -0400
In-Reply-To: <20120517150157.GA19274@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Thu, 17 May 2012 17:01:57 +0200

>>From 6da6a21798d0156e647a993c31782eec739fa5df Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 17 May 2012 16:48:56 +0200
> Subject: [PATCH] tcp: force push data out when buffers are missing
> 
> Commit 2f533844242 (tcp: allow splice() to build full TSO packets)
> significantly improved splice() performance for some workloads but
> caused stalls when pipe buffers were larger than socket buffers.
> 
> The issue seems to happen when no data can be copied at all due to
> lack of buffers, which results in pending data never being pushed.
> 
> This change checks if all pending data has been pushed or not and
> pushes them when waiting for send buffers.

Eric, please indicate whether we need Willy's patch here.

I want to propagate this fix as fast as possible if so.
