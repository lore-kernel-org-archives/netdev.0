From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [RFC/PATCH] lockless loopback patch for 2.6 (version 2)
Date: Mon, 14 Jun 2004 12:45:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0406141243360.479900@neteng.engr.sgi.com>
References: <Pine.SGI.4.56.0406141000060.479900@neteng.engr.sgi.com>
 <20040614182336.GC11280@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20040614182336.GC11280@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mon, 14 Jun 2004, Mitchell Blank Jr wrote:

> Arthur Kepner wrote:
> > +#define HARD_TX_LOCK_BH(dev, cpu) {			\
> > +	if ( dev->features && NETIF_F_LLTX  == 0 ) {	\
>                            ^^
>
> Don't you mean '&' instead of '&&' here?  It looks like that condition is
> always false, so you've killed the TX locking for all devices with this
> patch.

Ummm, yes. (I believe the appropriate response here is "D'oh!") Thanks.

--

Arthur
