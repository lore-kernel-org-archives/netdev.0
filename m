From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] ipx - set socket owner field
Date: Sun, 31 Aug 2003 14:35:30 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030831173530.GF29218@conectiva.com.br>
References: <20030829113704.548a9af4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030829113704.548a9af4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Aug 29, 2003 at 11:37:04AM -0700, Stephen Hemminger escreveu:
> All sockets created by a protocol need to have owner field set
> to prevent problems with orphaned sockets during module unload.
> 
> Patch for 2.6.0-test4
> 
> diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
> --- a/net/ipx/af_ipx.c	Fri Aug 29 11:20:48 2003
> +++ b/net/ipx/af_ipx.c	Fri Aug 29 11:20:48 2003
> @@ -1365,6 +1365,7 @@
>  			atomic_read(&ipx_sock_nr));
>  #endif
>  	sock_init_data(sock, sk);
> +	sk_set_owner(sk, THIS_MODULE);
>  	sk->sk_no_check = 1;		/* Checksum off by default */
>  	rc = 0;
>  out:

Thanks Stephen, I'm having problems with my home network for the last week or
so, so have been pretty much unresponsive, will be looking over all this and
the appletalk test (yes, I haven't forgotten that one) as soon as possible.

- Arnaldo
