From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 15:30:20 -0800
Message-ID: <20050125153020.3f3256fb.davem@davemloft.net>
References: <20050124164049.3b939791.davem@davemloft.net>
	<20050125014538.GB31837@postel.suug.ch>
	<20050125014838.GA16637@gondor.apana.org.au>
	<20050125020118.GC31837@postel.suug.ch>
	<20050124180354.63ae600d.davem@davemloft.net>
	<20050125022431.GD31837@postel.suug.ch>
	<20050124194328.20a106de.davem@davemloft.net>
	<20050125143319.GF31837@postel.suug.ch>
	<20050125203607.GG31837@postel.suug.ch>
	<41F6B090.6020602@candelatech.com>
	<20050125211524.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, herbert@gondor.apana.org.au,
        david@davidcoulson.net, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050125211524.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 22:15:24 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> I thought about this too and actually implemented it but it means to
> change all relevant drivers and the only feature that might be
> driver specific is checksumming, given I didn't make any mistakes
> while checking the drivers for pskb compatibility.

It is not only checksumming, but also TSO.  TSO, like checksumming,
is a feature where the chip must parse the packet to figure out where
to do it's work.  In fact, TSO is a prime suspect for VLAN problems
as the card must duplicate the VLAN headers properly as it chops
up the TSO frame into MSS sized pieces.
