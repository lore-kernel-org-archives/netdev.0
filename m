From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Sun, 23 Jan 2005 20:38:07 -0800
Message-ID: <20050123203807.5e101123.davem@davemloft.net>
References: <20050124005348.GL23931@postel.suug.ch>
	<E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
	<20050123202715.281ac87c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, kaber@trash.net,
        david@davidcoulson.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050123202715.281ac87c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 23 Jan 2005 20:27:15 -0800
"David S. Miller" <davem@davemloft.net> wrote:

> If some code underruns
> skb->data somehow while unfragging/refragging, that's a sure
> fire way to corrupt things such as the skb->ip_summed field.

Ignore this, I'm wrong.  We allocate sk_buff and skb->data
seperately, so this can't happen.

I'm really showing my age, because many moons ago we did
allocate them together :-)
