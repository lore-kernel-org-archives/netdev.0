From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] take2: new module infrastructure for net_proto_family
Date: Sun, 20 Apr 2003 12:41:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030420.124156.41659216.davem@redhat.com>
References: <20030419.184122.74731778.davem@redhat.com>
	<20030420160218.GB8399@conectiva.com.br>
	<20030420161008.GC8399@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030420161008.GC8399@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Sun, 20 Apr 2003 13:10:08 -0300

   Em Sun, Apr 20, 2003 at 01:02:18PM -0300, Arnaldo C. Melo escreveu:
   > humm, I'll work on this later today, tweaking sk_alloc/sk_free.
   
   as net_families is static in net/socket.c we'll need npf_get and npf_put
   (net proto family get/put), is the naming OK for you?

I'd prefer net_family_{get,put}().
