From: Steve Hill <steve@services.navaho.net>
Subject: Re: More IPSEC trouble
Date: Mon, 14 Mar 2005 12:12:27 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0503141211170.18067@sorbus2.navaho>
References: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au>
 <Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho> <42323125.20706@trash.net>
 <20050312013515.GA17539@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050312013515.GA17539@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Mar 2005, Herbert Xu wrote:

> Since tunnel_check_size only looks at the state to determine whether
> it's tunnel mode, it doesn't need to hold the lock at all.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I can confirm this fixes the problem - tested under 2.6.10.


- Steve Hill (BSc)
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015
