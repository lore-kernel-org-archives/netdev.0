From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irtty-sir.c: Do not set_termios() on irtty_close()
Date: Mon, 17 Feb 2014 14:29:32 -0500 (EST)
Message-ID: <20140217.142932.2241202017756551476.davem@davemloft.net>
References: <52FC87B6.4070001@gannert.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tommie@gannert.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FC87B6.4070001@gannert.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tommie Gannert <tommie@gannert.se>
Date: Thu, 13 Feb 2014 08:52:06 +0000

> --- linux-3.12/drivers/net/irda/irtty-sir.c.orig 2014-02-12
> --- 21:36:46.132496089 +0000
> +++ linux-3.12/drivers/net/irda/irtty-sir.c 2014-02-12
> 21:57:21.635843884 +0000
> @@ -521,7 +521,6 @@ static void irtty_close(struct tty_struc
>  	sirdev_put_instance(priv->dev);
>    	/* Stop tty */
> -	irtty_stop_receiver(tty, TRUE);
>  	clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
>  	if (tty->ops->stop)
>  		tty->ops->stop(tty);

This patch has been corrupted by your email client.  Please fix this
up and resubmit, thanks.
