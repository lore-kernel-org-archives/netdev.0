From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 28 Sep 2004 22:59:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096426760.1042.136.camel@jzny.localdomain>
References: <20040927213607.GD7243@gondor.apana.org.au>
	 <1096339407.8660.33.camel@jzny.localdomain>
	 <20040928024614.GA9911@gondor.apana.org.au>
	 <1096340772.8659.51.camel@jzny.localdomain>
	 <20040928032321.GB10116@gondor.apana.org.au>
	 <1096343125.8661.96.camel@jzny.localdomain>
	 <20040928035921.GA10675@gondor.apana.org.au>
	 <1096367787.8662.146.camel@jzny.localdomain> <4159D278.4060809@eurodev.net>
	 <1096424914.1043.103.camel@jzny.localdomain>
	 <20040929023051.GA26716@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040929023051.GA26716@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 22:30, Herbert Xu wrote:
> On Tue, Sep 28, 2004 at 10:28:34PM -0400, jamal wrote:
> > 
> > Being able to prioritize control (errors and ACKs) would be valuable.
> > Would require mucking around with the socket queue. 
> > Something along what we do for a basic default 3 band queue (proabably
> > two band in this case) should work.
> 
> Obviously neither of you have taken my tip :)
> 
> You should never use your unicast socket to receive multicast messages.
> Otherwise you get to keep both pieces when it breaks.

Ok, good point as long as it is common knowledge. 

cheers,
jamal
