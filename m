From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Mon, 17 Jun 2002 23:49:34 -0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020618024934.GA4274@conectiva.com.br>
References: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk> <20020617.143319.54623892.davem@redhat.com> <20020618005735.GB1146@conectiva.com.br> <20020617.191726.55300824.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: critson@perlfu.co.uk, torvalds@transmeta.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020617.191726.55300824.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Em Mon, Jun 17, 2002 at 07:17:26PM -0700, David S. Miller escreveu:
>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
>    Date: Mon, 17 Jun 2002 21:57:35 -0300
> 
>    --- orig/net/ipv6/tcp_ipv6.c	Sat May 25 23:13:56 2002
>    +++ linux/net/ipv6/tcp_ipv6.c	Fri Jun 14 23:23:07 2002
> 
> I've installed this change into my tree in the meantime.
> If we find a better fix, we can just revert this.

OK, I found a better fix, I think, that allowed me to kill inet6_sk_generic
in af_inet6.c, using a constructor for the tcpv6, udpv6 and raw6 slab caches,
as suggested by Russel King, I'll be sending RSN.

- Arnaldo
