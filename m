From: David Coulson <david@davidcoulson.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 09:51:24 -0500
Message-ID: <41F50B6C.6010107@davidcoulson.net>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050124121610.GP23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Thomas Graf wrote:
> Yes, this might clear things up.

10.1.1.5 is a production NS, so there is >500kbit/sec of DNS traffic to 
the box. Do you want me to restrict tcpdump to the /24 we were seeing 
traffic from which broke the kernel, or dump everything and send the 
part from around when the kernel fails?

> David, can you do this? and fix my patch by changing
> 
> 	if (skb->h.raw < skb->data || skb->h.raw > skb->data)
> into:
> 	if (skb->h.raw < skb->data || skb->h.raw > skb->tail)

Done

David

-- 
David J. Coulson
email: david@davidcoulson.net
web: http://www.davidcoulson.net/
phone: (216) 920-3100 / (216) 258-4942
