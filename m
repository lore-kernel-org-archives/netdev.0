From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 28 Sep 2004 22:28:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096424914.1043.103.camel@jzny.localdomain>
References: <20040923120707.GB32624@gondor.apana.org.au>
	 <1095995042.1044.34.camel@jzny.localdomain>
	 <20040924032440.GB6384@gondor.apana.org.au>
	 <1096289189.1075.37.camel@jzny.localdomain>
	 <20040927213607.GD7243@gondor.apana.org.au>
	 <1096339407.8660.33.camel@jzny.localdomain>
	 <20040928024614.GA9911@gondor.apana.org.au>
	 <1096340772.8659.51.camel@jzny.localdomain>
	 <20040928032321.GB10116@gondor.apana.org.au>
	 <1096343125.8661.96.camel@jzny.localdomain>
	 <20040928035921.GA10675@gondor.apana.org.au>
	 <1096367787.8662.146.camel@jzny.localdomain> <4159D278.4060809@eurodev.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <4159D278.4060809@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 17:07, Pablo Neira wrote:

> I'm also thinking in doing something with netlink_ack's since they can 
> be drop if buffer is full. We could give more priority to error messages 
> in some way, for example, check if there's space for an error message in 
> the buffer, if there's not, drop as many packets in buffer as we get 
> space to enqueue the error message.

Being able to prioritize control (errors and ACKs) would be valuable.
Would require mucking around with the socket queue. 
Something along what we do for a basic default 3 band queue (proabably
two band in this case) should work.

cheers,
jamal
