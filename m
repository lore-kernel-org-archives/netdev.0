From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol
 modules
Date: Mon, 28 Apr 2003 23:00:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030428.230034.08345606.davem@redhat.com>
References: <20030429061227.GJ25361@conectiva.com.br>
	<20030428.222728.48508327.davem@redhat.com>
	<20030429065419.GN25361@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@speakeasy.net, netdev@oss.sgi.com, maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030429065419.GN25361@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Tue, 29 Apr 2003 03:54:19 -0300

   Em Mon, Apr 28, 2003 at 10:27:28PM -0700, David S. Miller escreveu:
   > Although the idea is conceptually sound, you miss one crucial thing.
   > Such struct sock's reference _TWO_ modules, the "PPPOE" module
   > and the "PPPOX" module.
   
   But what is the problem? at pppox_sk_alloc time I bump the PPPOE
   module refcnt, making it safe, then it calls sk_alloc where it
   bumps the PPPOX module, making it safe as well, so I'm taking care
   of both PPPOE and PPPOX.

You're absolutely correct, I missed this.

I'll pull your changes, thanks.
