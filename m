From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/4] net: avoid false perf interpretations in
 frag code
Date: Thu, 25 Apr 2013 15:13:42 -0400 (EDT)
Message-ID: <20130425.151342.268372510252765918.davem@davemloft.net>
References: <20130424154836.16883.79599.stgit@dragon>
	<1366847307.8964.89.camel@edumazet-glaptop>
	<1366887428.26911.542.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755921Ab3DYTNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 15:13:45 -0400
In-Reply-To: <1366887428.26911.542.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 25 Apr 2013 12:57:08 +0200

> Would we add the "inlines" only to the code, to make it clear what is
> happening in the code?

Never add inline in *.c code, in *.h headers, let the compiler sort it out.
