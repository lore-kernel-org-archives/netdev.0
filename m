From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] take2: new module infrastructure for net_proto_family
Date: Sun, 20 Apr 2003 13:02:18 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030420160218.GB8399@conectiva.com.br>
References: <20030419233408.GG6251@conectiva.com.br> <20030419.184122.74731778.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030419.184122.74731778.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sat, Apr 19, 2003 at 06:41:22PM -0700, David S. Miller escreveu:
> Note that, eventually we'll need to handle the struct sock side of this
> equation.  Consider that struct sock's can exist long after the user struct
> socket is closed (TCP is the best example), yet they reference internals to
> the protocol module (via sk and skb callbacks, hash table linkage, etc.).

humm, I'll work on this later today, tweaking sk_alloc/sk_free.

> We can deal with this later, let's merge your stuff in first.

Thanks, now to easter lunch :-)

- Arnaldo
