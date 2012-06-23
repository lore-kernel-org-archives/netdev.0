From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache output dst for
 syncookies
Date: Fri, 22 Jun 2012 21:47:56 -0700 (PDT)
Message-ID: <20120622.214756.986537250019391171.davem@davemloft.net>
References: <1340204539.4604.1122.camel@edumazet-glaptop>
	<1340365654.4003.46.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757244Ab2FWEr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 00:47:59 -0400
In-Reply-To: <1340365654.4003.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 22 Jun 2012 13:47:34 +0200

> On Wed, 2012-06-20 at 17:02 +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Don't cache output dst for syncookies, as this adds pressure on IP route
>> cache and rcu subsystem for no gain.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> Looks good to me.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks.
