From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: FreeSWAN's pfkey_v2.c
Date: Wed, 16 Oct 2002 23:53:47 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017025347.GF7541@conectiva.com.br>
References: <200210170248.g9H2m6bf011892@marajade.sandelman.ottawa.on.ca> <20021017045054.A405@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Richardson <mcr@sandelman.ottawa.on.ca>, design@lists.freeswan.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20021017045054.A405@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Thu, Oct 17, 2002 at 04:50:54AM +0200, Andi Kleen escreveu:
> > I am looking for confirmation from network stack people that my conclusions
> > from reading of the macros in linux/net.h is correct.
> 
> What you should actually do is to add explicit proper SMP locking.
> Then you don't need any SOCKOPS_WRAP hacks.

yup, so that eventually we can kill this hackish bandaid.

- Arnaldo
