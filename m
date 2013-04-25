From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Thu, 25 Apr 2013 07:37:23 -0700
Message-ID: <1366900643.8964.152.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
	 <1366855546.8964.125.camel@edumazet-glaptop>
	 <1366898779.26911.609.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:65089 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab3DYOh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 10:37:26 -0400
Received: by mail-pa0-f48.google.com with SMTP id lj1so1886318pab.21
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 07:37:25 -0700 (PDT)
In-Reply-To: <1366898779.26911.609.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 16:06 +0200, Jesper Dangaard Brouer wrote:

> I like this idea (just don't know how to implement it).  As my perf
> results with "direct-hash-cleaning", show that we can hit a very
> unfortunate situation, where the add/remove timer spinlock gets
> hot/congested.

Remove the timer per frag, problem solved ;)

With one million frags around, we do not want one million active timers.
