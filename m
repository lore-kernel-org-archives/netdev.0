From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/4] packet: Add pre-defragmentation support for ipv4
Date: Thu, 07 Jul 2011 00:25:03 -0700 (PDT)
Message-ID: <20110707.002503.951663853832906838.davem@davemloft.net>
References: <1309965489.2292.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110706.082040.1487690721120263418.davem@davemloft.net>
	<1309966077.2292.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mika.penttila@ixonos.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab1GGHZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 03:25:10 -0400
In-Reply-To: <1309966077.2292.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jul 2011 17:27:57 +0200

> We probably need to add some atomic_inc(&sk->sk_drops) to at least
> warn the application.

I fully support adding some kind of statistics support to AF_PACKET
sockets.
