From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 06/12] hamradio: add missing sanity check to tty operation
Date: Thu, 07 Aug 2008 02:23:54 -0400
Message-ID: <489A94FA.3000808@garzik.org>
References: <200807301938.m6UJcxbO012515@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugeneteo@kernel.sg, alan@redhat.com,
	eteo@redhat.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53810 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507AbYHGGX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:23:58 -0400
In-Reply-To: <200807301938.m6UJcxbO012515@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Eugene Teo <eugeneteo@kernel.sg>
> 
> Add missing sanity check to tty operation.
> 
> Acked-by: Alan Cox <alan@redhat.com>
> Signed-off-by: Eugene Teo <eteo@redhat.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/hamradio/mkiss.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/hamradio/mkiss.c~hamradio-add-missing-sanity-check-to-tty-operation drivers/net/hamradio/mkiss.c
> --- a/drivers/net/hamradio/mkiss.c~hamradio-add-missing-sanity-check-to-tty-operation
> +++ a/drivers/net/hamradio/mkiss.c
> @@ -548,7 +548,7 @@ static int ax_xmit(struct sk_buff *skb, 
>  		}
>  
>  		printk(KERN_ERR "mkiss: %s: transmit timed out, %s?\n", dev->name,
> -		       (ax->tty->ops->chars_in_buffer(ax->tty) || ax->xleft) ?
> +		       (tty_chars_in_buffer(ax->tty) || ax->xleft) ?
>  		       "bad line quality" : "driver error");
>  
>  		ax->xleft = 0;

applied


