From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Thu, 25 Apr 2013 12:22:35 -0700
Message-ID: <1366917755.8964.179.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
	 <1366898369.26911.604.camel@localhost>
	 <1366899530.8964.150.camel@edumazet-glaptop>
	 <1366917347.26911.624.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:60263 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758453Ab3DYTWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 15:22:37 -0400
Received: by mail-da0-f50.google.com with SMTP id a4so1540445dad.23
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 12:22:37 -0700 (PDT)
In-Reply-To: <1366917347.26911.624.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 21:15 +0200, Jesper Dangaard Brouer wrote:

> > Q) You want performance and big number of frags to cope with attacks
> > A) resize the hash table when the admin sets a bigger limit
> 
> Q) How do we solve the per netns limit vs hash size? (Make limit
> global?)

global limit would be needed anyway.

If we want a per netns limit, that would be a second (per netns)
percpu_counter, but I feel this can be added later.

Thanks !
