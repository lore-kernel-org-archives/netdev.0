From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO v3
Date: Mon, 23 May 2005 14:50:01 -0700 (PDT)
Message-ID: <20050523.145001.104034315.davem@davemloft.net>
References: <20050523.121943.78708600.davem@davemloft.net>
	<E1DaKZK-0006Qv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1DaKZK-0006Qv-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 May 2005 07:34:38 +1000

> Are there non-Linux systems that have the same receive issue?

Some generate stretch ACKs for other reasons (miscalculation
of MSS due to TCP Timestamps) but I doubt any other OS
implements the Van Jacobson ucopy stuff we do, and also
implement the same ACKing hack on top of that :-)
