From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] merge sctp_opt with sctp_sock
Date: Mon, 17 Jan 2005 13:33:27 -0800
Message-ID: <20050117133327.0386763f.davem@davemloft.net>
References: <41E8A17D.9040307@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41E8A17D.9040307@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 02:52:13 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> 	Please take a look and if its acceptable pull from:
> 
> bk://kernel.bkbits.net/acme/connection_sock-2.6
> 
> 	The tricky bit here is that SCTP, to keep the existing logic,
> needs a way to copy only its private area from one sock to another, so
> I introduced a generic inet_sk_copy_descendant, that knows about the
> inet (v4/v6) layout (wrt inet_sock and inet6_pinfo), using this and
> sk->sk_prot->slab_obj_size we can copy the inet_sock descendant
> private area generically.

This looks fine, although I wish the descendant copying thing
could be done more cleanly somehow.

Pulled.
