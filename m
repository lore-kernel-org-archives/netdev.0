From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 6/9] irda: use sock slab cache
Date: Wed, 19 Jan 2005 18:16:07 -0800
Message-ID: <20050120021607.GA11216@bougret.hpl.hp.com>
References: <41EF11AF.70203@conectiva.com.br>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <41EF11AF.70203@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 20, 2005 at 12:04:31AM -0200, Arnaldo Carvalho de Melo wrote:
> Hi David, Jean,
> 
> 	Please read the log in the patch.
> 
> Regards,
> 
> - Arnaldo
> 

> ===================================================================
> 
> 
> ChangeSet@1.2342, 2005-01-19 23:04:52-02:00, acme@toy.ghostprotocols.net
>   [IRDA] use a private slab cache for socks
>   
>   Required to get rid of sk_protinfo and to introduce struct connection_sock,
>   also for consistency with other protocol families implementations.

	I don't have anything against this patch, as it looks clean
and straightforward. Stephen might have something to say. I'm way
behind, so it may take a while before I test that.
	I'm just curious about the overhead of adding a specific slab
for IrDA sockets. Most users never create any (using IrCOMM), or
maximum one (using Obex), so it's not like it will get a lot of use
(except here, of course).

	Thanks, and have fun...

	Jean
