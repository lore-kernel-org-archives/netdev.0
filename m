From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 11:07:59 +1100
Message-ID: <20050125000759.GA15883@gondor.apana.org.au>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch> <20050124225423.GA15405@gondor.apana.org.au> <20050124234515.GA31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Coulson <david@davidcoulson.net>,
        "David S. Miller" <davem@davemloft.net>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050124234515.GA31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 25, 2005 at 12:45:15AM +0100, Thomas Graf wrote:
> 
> I don't quite understand how this solves the problem. How could
> ip_summed be non zero after ip_forward? The earliest possible call
> to ip_fragment is in postrouting. Please correct me if I'm wrong.

ip_forward only sets ip_summed for the packet at the head.  It does
not clear ip_summed for the fragments themselves.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
