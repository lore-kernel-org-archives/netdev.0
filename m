From: Patrick McHardy <kaber@trash.net>
Subject: Re: More IPSEC trouble
Date: Sat, 12 Mar 2005 03:35:46 +0100
Message-ID: <42325582.1090003@trash.net>
References: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho> <42323125.20706@trash.net> <20050312013515.GA17539@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Hill <steve@services.navaho.net>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050312013515.GA17539@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Good catch.  However let's try to avoid spreading lock/unlock calls
> around if possible.
> 
> Since tunnel_check_size only looks at the state to determine whether
> it's tunnel mode, it doesn't need to hold the lock at all.

Agreed, your patch is better.

Regards
Patrick
