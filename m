From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] (2/11) netrom - shorten destroy timeout
Date: Thu, 14 Aug 2003 14:23:13 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814172312.GC1785@conectiva.com.br>
References: <20030813153920.68d52970.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>,
   netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030813153920.68d52970.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Aug 13, 2003 at 03:39:20PM -0700, Stephen Hemminger escreveu:
> 
> From: Jeroen Vreeken <pe1rxq@amsat.org>
> 
> Expire sockets faster on close
> 
> diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
> --- a/net/netrom/af_netrom.c	Wed Aug 13 11:58:31 2003
> +++ b/net/netrom/af_netrom.c	Wed Aug 13 11:58:31 2003
> @@ -269,7 +269,7 @@
>  	    atomic_read(&sk->sk_rmem_alloc)) {
>  		/* Defer: outstanding buffers */
>  		init_timer(&sk->sk_timer);
> -		sk->sk_timer.expires  = jiffies + 10 * HZ;
> +		sk->sk_timer.expires  = jiffies + 2 * HZ;

has this to be a magic fixed number? sysctl?
