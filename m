From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/12] remove sk_protinfo series
Date: Tue, 25 Jan 2005 22:24:28 -0800
Message-ID: <20050125222428.6b076cb1.davem@davemloft.net>
References: <41F07497.4020109@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41F07497.4020109@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 01:18:47 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> 	This series addresses Christoph and Jean concerns about the overhead
> caused by private slab caches in every family, by making sk_alloc use kmalloc
> if no slab cache is used, and as a transitional mechanism the zero_it
> semantic is maintained, that is, if slab is NULL and zero_it is 1, use the
> generic "slab" (sk_cachep) cache.

I think we'll need to defer this to 2.6.12

When I setup my 2.6.12 net pending queue tomorrow I'll pull from
your tree.  I'll probably set this up tomorrow and it will be at:

	bk://kernel.bkbits.net/davem/net-2.6.12

I'll announce it.
