From: jamal <hadi@cyberus.ca>
Subject: Re: TBF timing issues
Date: Sat, 10 Aug 2002 10:34:19 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208101031590.3494-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0208081127240.27547-100000@r2d2.sics.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Gabriel Paues <gabriel@sics.se>
In-Reply-To: <Pine.LNX.4.44.0208081127240.27547-100000@r2d2.sics.se>
List-Id: netdev.vger.kernel.org


UML will never work well. The issue is related to the timer effects
in UML. I believe its more of a clock skew and innacuracy than TBF making
assumptions.

cheers,
jamal

On Thu, 8 Aug 2002, Gabriel Paues wrote:

> Hello!
>
> I use the TBF filter with good results on my computer. When I set a rate
> with the filter the traffic get shaped accordingly.
>
> I have set up a couple of UML-instances (user-mode-linux) as a network
> to test different QoS strategies. My problem is that the TBF calculates
> the wrong rates. An UML-instance may get interrupted just like any other
> program. Does the timing code in TBF presume that the kernel wont be
> interrupted, and therefore generates the wrong rates?
>
> Ragards,
>
> Gabriel Paues
>
