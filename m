From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (4/4) acenic - don't spin forever in hard_start_xmit
Date: Mon, 20 Sep 2004 11:46:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920114627.4968a4fa.davem@davemloft.net>
References: <20040920104724.2a5d2b47@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040920104724.2a5d2b47@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 10:47:24 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> +	/* The ring is stuck full. */
> +	printk(KERN_WARNING "%s: Transmit ring stuck full\n", dev->name);
> +	return NETDEV_TX_BUSY;

OK, but only because it's a long timeout and the kernel log
gets a reasonable message.
