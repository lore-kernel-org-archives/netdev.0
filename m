From: Gabriel Paues <gabriel@sics.se>
Subject: TBF timing issues
Date: Thu, 8 Aug 2002 11:31:40 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208081127240.27547-100000@r2d2.sics.se>
References: <3D4768DC.7070907@cdac.ernet.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <3D4768DC.7070907@cdac.ernet.in>
List-Id: netdev.vger.kernel.org

Hello!

I use the TBF filter with good results on my computer. When I set a rate
with the filter the traffic get shaped accordingly.

I have set up a couple of UML-instances (user-mode-linux) as a network
to test different QoS strategies. My problem is that the TBF calculates
the wrong rates. An UML-instance may get interrupted just like any other
program. Does the timing code in TBF presume that the kernel wont be 
interrupted, and therefore generates the wrong rates?

Ragards,

Gabriel Paues
