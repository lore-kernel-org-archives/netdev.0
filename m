From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC/PATCH] lockless loopback patch for 2.6 (version 2)
Date: Mon, 14 Jun 2004 11:23:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614182336.GC11280@gaz.sfgoth.com>
References: <Pine.SGI.4.56.0406141000060.479900@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.56.0406141000060.479900@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arthur Kepner wrote:
> +#define HARD_TX_LOCK_BH(dev, cpu) {			\
> +	if ( dev->features && NETIF_F_LLTX  == 0 ) {	\
                           ^^

Don't you mean '&' instead of '&&' here?  It looks like that condition is
always false, so you've killed the TX locking for all devices with this
patch.

> +	if ( dev->features && NETIF_F_LLTX  == 0 ) {	\

ditto

-Mitch
