From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2.5.69] net/ipv6 missing kmem_cache_destroy in module exit
Date: Tue, 13 May 2003 23:46:29 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514024629.GF28128@conectiva.com.br>
References: <1052864772.2442.8.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>, davem@redhat.com,
   kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@intercode.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel McNeil <daniel@osdl.org>
Content-Disposition: inline
In-Reply-To: <1052864772.2442.8.camel@ibm-c.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, May 13, 2003 at 03:26:13PM -0700, Daniel McNeil escreveu:
> ipv6 is missing the calls to kmem_cache_destory() in module_exit
> and some cleanup routines.

Thanks, this was overlooked because IPv6 doesn't unloads 8) But this may
well change if we get to some solution to the complex subsystem module handling
that is being discussed recently.

- Arnaldo
