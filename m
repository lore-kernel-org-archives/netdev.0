From: Carl Ritson <critson@perlfu.co.uk>
Subject: Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Tue, 18 Jun 2002 08:38:48 +0100 (BST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <aemo82$kfm$2@main.gmane.org>
References: <20020618005735.GB1146@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>,
   Linus Torvalds <torvalds@transmeta.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20020618005735.GB1146@conectiva.com.br>
List-Id: netdev.vger.kernel.org

On Mon, 17 Jun 2002, Arnaldo Carvalho de Melo wrote:

> Em Mon, Jun 17, 2002 at 02:33:19PM -0700, David S. Miller escreveu:
> > 
> > This is a known bug introduced by the struct sock splitup into
> > external per-protocol pieces done by Arnaldo de Melo.  He is working
> > on the proper fix, your proposed change will just paper over the real
> > bug.

I suspected something like that.

> Carl,
> 
> 	Can you try this patch?
> 
> - Arnaldo
> 
> --- orig/net/ipv6/tcp_ipv6.c    Sat May 25 23:13:56 2002
> +++ linux/net/ipv6/tcp_ipv6.c   Fri Jun 14 23:23:07 2002
> <diff snipped> 

This patch doesn't help, it produces exactly the same oops when decoded, I 
assume the newer patch you mention to Dave is the correct fix?

Thanks,
Carl
