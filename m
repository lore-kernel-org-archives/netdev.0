From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache output dst for syncookies
Date: Fri, 22 Jun 2012 13:47:34 +0200
Message-ID: <1340365654.4003.46.camel@localhost>
References: <1340204539.4604.1122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755550Ab2FVLrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2012 07:47:41 -0400
In-Reply-To: <1340204539.4604.1122.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 17:02 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Don't cache output dst for syncookies, as this adds pressure on IP route
> cache and rcu subsystem for no gain.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Looks good to me.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
