From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Mon, 18 Apr 2005 12:17:11 +0200
Message-ID: <20050418101711.GP4114@postel.suug.ch>
References: <20050411125113.GL26731@postel.suug.ch> <E1DNLfx-0000yd-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fmp@palmen.homeip.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DNLfx-0000yd-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1DNLfx-0000yd-00@gondolin.me.apana.org.au> 2005-04-18 12:07
> Thomas Graf <tgraf@suug.ch> wrote:
> > 
> > OK, I think the problem is a few missing dev_hold() when the net_device
> > handle is assigned to routes, probes, etc.
> 
> Indeed.  Here is a patch that adds the references that are held by
> the routes.

Thanks for taking over Herbert, I simply didn't have the time lately.
The patch looks perfectly fine to me.
