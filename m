From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Make z8530.c build on 2.6
Date: 13 Aug 2003 23:23:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060813424.9130.61.camel@dhcp23.swansea.linux.org.uk>
References: <20030813132501.01eb1ecf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Nenad Corbic <ncorbic@sangoma.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030813132501.01eb1ecf.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mer, 2003-08-13 at 21:25, Stephen Hemminger wrote:
> Either we need to mark this driver (and the parts that use them) as BROKEN,
> or at least get it building again.

It works fine.

> -	c->rx_buf[0]=(void *)get_free_page(GFP_KERNEL|GFP_DMA);
> +	c->rx_buf[0]=(void *)get_zeroed_page(GFP_KERNEL|GFP_DMA);

and doesn't need zeroed pages, I've just got no idea what 2.6 decided
to call the give me a free page function, fix that and it'll work fine.

(BTW its not one of the sangoma drivers but something I wrote originally
so Nenad isnt the guy to cc)
