From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 21 Sep 2004 22:53:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095821624.1045.6.camel@jzny.localdomain>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <4150E7E5.2000001@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 22:48, Pablo Neira wrote:
> jamal wrote:
> 
> >For a test i typically have something adding say 10K items (actions in
> >my case, but could be ipsec policies) and then try to dump them. On my
> >xeon i get an overrun after about 6K items are dumped.
> >
> 
> Jamal, you're getting an overrun dumping ipsec policies. If I'm not 
> wrong, that tool is doing that as dump operation, but that this 
> shouldn't happen by using dump. Am I missing something?

Its not ipsec policies, rather tc actions - but i expect the same to
happen to ipsec policies being dumped..

> I would like to have a way to send notifications via netlink sockets 
> without losing congestion control ability, that is, without losing 
> messages because of an overrun.

This is a legit requirement. It is also legit to be able to do so for
just a basic get request (not a dump). Nothing in the semantics of
netlink says that it should work in one way or the other only.

cheers,
jamal

BTW, I was never able to dload your code; i think you might have taken
it offline?
