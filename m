From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] Move local_bh_disable back in dev_queue_xmit
Date: Wed, 3 Nov 2004 12:50:30 -0800
Message-ID: <20041103125030.211d9833.davem@davemloft.net>
References: <20041102225406.GA13760@gondor.apana.org.au>
	<4188EFD1.4050909@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mingo@elte.hu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4188EFD1.4050909@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 03 Nov 2004 15:48:49 +0100
Tommy Christensen <tommy.christensen@tpack.net> wrote:

> Herbert Xu wrote:
> > Hi Ingo:
> > 
> > Your recent fix to dev_queue_xmit moved the local_bh_disable to
> > include stuff like skb_linearize and skb_checksum_help.  These
> > are potentially expensive operations.  Since they don't need to
> > run with preempt off, we could simply move the local_bh_enable
> > up instead.
> 
> No, this breaks the normal return path.
> 
> How about this instead?

Yep, this one is better.  Patch applied, thanks everyone.
