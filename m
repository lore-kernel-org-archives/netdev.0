From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 19 Sep 2004 18:39:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095633569.1047.107.camel@jzny.localdomain>
References: <414D0CCD.90209@eurodev.net>
	 <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040919215915.GB9573@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Theres one valuable piece in his patch. Ability to congestion control
the kernel so user space can clear the socket queue. The alternative is
an overun. You have shot a hole in the workqueue approach. May i also
recommend we revert the patch until we have a better resolution, Dave?

Pablo you really need to provide some good testcases to prove this.
I have my own netlink stress testing that i havent gotten around to
testing this issue. 

cheers,
jamal
