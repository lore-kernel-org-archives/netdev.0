From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Thu, 25 Apr 2013 07:10:26 -0700
Message-ID: <1366899026.8964.142.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
	 <1366898369.26911.604.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:62444 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757277Ab3DYOK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 10:10:28 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so1436367dad.18
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 07:10:28 -0700 (PDT)
In-Reply-To: <1366898369.26911.604.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 15:59 +0200, Jesper Dangaard Brouer wrote:

>  We don't need that much memory to "protect" fragment from slow sender,
> with the LRU system.

Only on your particular synthetic workload.

A slow sender sends one frame per second.

You need at least 1GB of memory to cope with that. 
