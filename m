From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 12:48:38 +1100
Message-ID: <20050125014838.GA16637@gondor.apana.org.au>
References: <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch> <20050124225423.GA15405@gondor.apana.org.au> <20050124234515.GA31837@postel.suug.ch> <20050125000759.GA15883@gondor.apana.org.au> <20050124164049.3b939791.davem@davemloft.net> <20050125014538.GB31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, david@davidcoulson.net,
        kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050125014538.GB31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 25, 2005 at 02:45:38AM +0100, Thomas Graf wrote:
> 
> Still, one problem remains, even if ip_summed was incorrect,
> skb_checksum_help should never be called in dev_queue_xmit for the
> acenic driver since it sets NETIF_F_IP_CSUM. For some reason, features
> is set to 0 while checking for it.

Didn't he say that he cleared the features bits in the acenic driver?

BTW, is he using acenic for both the LAN and the WAN? If he's only
using it on the WAN side, then the LAN side might not be CSUM capable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
