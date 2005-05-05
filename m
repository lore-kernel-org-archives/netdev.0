From: Anton Blanchard <anton@samba.org>
Subject: Re: oops in ip_rcv
Date: Thu, 5 May 2005 23:09:04 +1000
Message-ID: <20050505130904.GA16593@krispykreme>
References: <20050505101542.GB7916@krispykreme> <E1DTeis-0005gu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DTeis-0005gu-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> Any idea why you'd be receiving packets this early?

Not sure, although PCI has already been probed and tcp_init is called
with interrupts on. Any reason we cant take a packet at this point?

Im guessing its calling this:

        IP_INC_STATS_BH(IPSTATS_MIB_INRECEIVES);

Which we dont initialise until later on in init_ipv4_mibs.

Anton
