From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Thu, 25 Apr 2013 21:15:47 +0200
Message-ID: <1366917347.26911.624.camel@localhost>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
	 <1366898369.26911.604.camel@localhost>
	 <1366899530.8964.150.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755613Ab3DYTPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 15:15:53 -0400
In-Reply-To: <1366899530.8964.150.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 07:18 -0700, Eric Dumazet wrote:

> Let be clear :
[cut Q&A worklist]

Thanks, that is perfect. I'll start working on it Monday (as tomorrow is
a public holiday, and my home gets invaded by family, who will be
sleeping in my office).

One more question:

> Q) You want performance and big number of frags to cope with attacks
> A) resize the hash table when the admin sets a bigger limit

Q) How do we solve the per netns limit vs hash size? (Make limit
global?)

--Jesper
