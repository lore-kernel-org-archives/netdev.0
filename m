From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Fw: Oops in 2.6.0-test[89] in tcp_v4_get_port (kernel with IPv6 enabled)
Date: Fri, 31 Oct 2003 21:14:00 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031231400.GV3705@conectiva.com.br>
References: <20031031145542.28e8b820.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Raffaele Brancaleoni <raffaele.brancaleoni@sun.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031031145542.28e8b820.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Oct 31, 2003 at 02:55:42PM -0800, Andrew Morton escreveu:
> 
> 
> Begin forwarded message:
> 
> Date: Fri, 31 Oct 2003 12:30:06 +0100
> From: Raffaele Brancaleoni <raffaele.brancaleoni@sun.com>
> To: linux-kernel@vger.kernel.org
> Subject: Oops in 2.6.0-test[89] in tcp_v4_get_port (kernel with IPv6 enabled)
> 
> 
> Hello everyone,
> 
> I just encountered a oops with kernels 2.6.0-test8 and -test9 (system
> freezes the hard way, not even magic-key works). Problem does not exist
> in 2.4.20.
> 
> It looks to me its a regression (or has it ever been integrated?) of
> bug 456 (from bugme.osdl.org) but I'm far from being an expert.
> 
> I can trigger it easily by running the test suite of mod_perl 1.99
> (it crashes systematically at the very end of the tests).

Ouch, it seems this one is a die hard, Rafaelle, could you please test it
without IPv6?

- Arnaldo
