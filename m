From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Fixed alg_key_len usage in attach_one_algo
Date: Thu, 19 May 2005 12:40:15 -0700 (PDT)
Message-ID: <20050519.124015.122255786.davem@davemloft.net>
References: <20050519020302.GA20285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050519020302.GA20285@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 19 May 2005 12:03:02 +1000

> This bug was discovered by a Linux box running in a remote corner
> of Australia :)

Hehe :-)

> The variable alg_key_len is in bits and not bytes.  The function
> attach_one_algo is currently using it as if it were in bytes.
> This causes it to read memory which may not be there.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
