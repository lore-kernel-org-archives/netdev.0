From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 21 Sep 2004 22:57:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095821845.1047.9.camel@jzny.localdomain>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040922000503.GA13218@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 20:05, Herbert Xu wrote:


> Secondly each of your user-space messages is producing a number of
> replies.  This should be done as a dump operation.  If you do it as
> a dump operation, then you will never get overruns because the kernel
> never sends more than the user can handle.

This is not accurate. You will get overruns. Try adding a few thousand
ipsec policies and then dumping them. Perhaps we can have the cb reset
in case of overrun detection.

cheers,
jamal
