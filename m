From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/2] tun: put correct method name in a debug
 message.
Date: Mon, 26 Nov 2012 14:31:19 -0800
Message-ID: <1353969079.2493.5.camel@joe-AO722>
References: <1353917261-2974-1-git-send-email-ramirose@gmail.com>
	 <1353917261-2974-3-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, maxk@qti.qualcomm.com, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55412 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932087Ab2KZWbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 17:31:20 -0500
In-Reply-To: <1353917261-2974-3-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 10:07 +0200, Rami Rosen wrote:
> This patch puts the correct method name, tun_do_read, in a debug message.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> ---
>  drivers/net/tun.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 1dfb135..607a3a5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1296,7 +1296,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
>  	struct sk_buff *skb;
>  	ssize_t ret = 0;
>  
> -	tun_debug(KERN_INFO, tun, "tun_chr_read\n");
> +	tun_debug(KERN_INFO, tun, "tun_do_read\n");

It's almost always better to use "%s\n", __func__

Of course for these sorts of trivial tracing functions,
it's better to use the function tracer instead.

http://lwn.net/Articles/370423/
