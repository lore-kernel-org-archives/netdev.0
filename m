From: "David S. Miller" <davem@davemloft.net>
Subject: Re: More IPSEC trouble
Date: Mon, 14 Mar 2005 21:39:15 -0800
Message-ID: <20050314213915.1cf98afc.davem@davemloft.net>
References: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au>
	<Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho>
	<42323125.20706@trash.net>
	<20050312013515.GA17539@gondor.apana.org.au>
	<Pine.LNX.4.61.0503141211170.18067@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net, netdev@oss.sgi.com
To: Steve Hill <steve@services.navaho.net>
In-Reply-To: <Pine.LNX.4.61.0503141211170.18067@sorbus2.navaho>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 12:12:27 +0000 (GMT)
Steve Hill <steve@services.navaho.net> wrote:

> On Sat, 12 Mar 2005, Herbert Xu wrote:
> 
> > Since tunnel_check_size only looks at the state to determine whether
> > it's tunnel mode, it doesn't need to hold the lock at all.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I can confirm this fixes the problem - tested under 2.6.10.

I've applied Herbert's patch, thanks guys.
