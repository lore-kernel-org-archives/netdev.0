From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 18:02:05 -0800
Message-ID: <20050124180205.2f0590e5.davem@davemloft.net>
References: <20050124005348.GL23931@postel.suug.ch>
	<E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
	<20050123202715.281ac87c.davem@davemloft.net>
	<20050124121610.GP23931@postel.suug.ch>
	<41F50B6C.6010107@davidcoulson.net>
	<20050124151510.GV23931@postel.suug.ch>
	<20050124225423.GA15405@gondor.apana.org.au>
	<20050124234515.GA31837@postel.suug.ch>
	<20050125000759.GA15883@gondor.apana.org.au>
	<20050124164049.3b939791.davem@davemloft.net>
	<20050125014538.GB31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050125014538.GB31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 02:45:38 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> As it seems, it is really the case, a first peeks shows that the
> following drivers set ip_summed to HW under some circumstances:
>  acenic, he, hamachi, starfire, sungem, happy meal

I looked this up too, and your list of drivers actually
using CHECKSUM_HW on RX seems accurate.
