From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 22 Sep 2004 08:08:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095854920.1047.64.camel@jzny.localdomain>
References: <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
	 <20040922045239.GA19573@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040922045239.GA19573@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-22 at 00:52, Herbert Xu wrote: 
> Congestion control similar to the way dumping works may work for you.

Note the initial goal was to have dump work for large tables and a
simple get for a basic table row.
Since netlink is being used for a lot of things now, it may be time to
obsolete those assumptions. 
Note also, theres a lot of wastage of that scarce sock buffer via page
sized skbs - its not as trivial to fix, but would go some way to improve
overrunning of the socket.

cheers,
jamal
