From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 03:24:31 +0100
Message-ID: <20050125022431.GD31837@postel.suug.ch>
References: <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch> <20050124225423.GA15405@gondor.apana.org.au> <20050124234515.GA31837@postel.suug.ch> <20050125000759.GA15883@gondor.apana.org.au> <20050124164049.3b939791.davem@davemloft.net> <20050125014538.GB31837@postel.suug.ch> <20050125014838.GA16637@gondor.apana.org.au> <20050125020118.GC31837@postel.suug.ch> <20050124180354.63ae600d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050124180354.63ae600d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050124180354.63ae600d.davem@davemloft.net> 2005-01-24 18:03
> > * Herbert Xu <20050125014838.GA16637@gondor.apana.org.au> 2005-01-25 12:48
> > > On Tue, Jan 25, 2005 at 02:45:38AM +0100, Thomas Graf wrote:
> > The packets get routed back over the same physical interface.
> 
> I think I see what is happening, it's the virtual VLAN device which
> has dev->features set to zero not the acenic's netdev struct.

This of course explains it, didn't think of that. I thought it would
inherit the checksumming features.
