From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] take2: new module infrastructure for net_proto_family
Date: Sat, 19 Apr 2003 18:41:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030419.184122.74731778.davem@redhat.com>
References: <20030419233408.GG6251@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030419233408.GG6251@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Sat, 19 Apr 2003 20:34:08 -0300

   	Please consider pulling from:
   
   bk://kernel.bkbits.net/acme/net-2.5
   
   	It has your suggestions implemented.
   
Pulled, thanks.

Note that, eventually we'll need to handle the struct sock side of
this equation.  Consider that struct sock's can exist long after the
user struct socket is closed (TCP is the best example), yet they
reference internals to the protocol module (via sk and skb
callbacks, hash table linkage, etc.).

We can deal with this later, let's merge your stuff in first.
