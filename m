From: John Heffner <jheffner@psc.edu>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 17:36:18 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409151704200.5383-100000@dexter.psc.edu>
References: <4148991B.9050200@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <leonid.grossman@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
In-Reply-To: <4148991B.9050200@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My view on TOE is that it is brought up in response to the fact that when
leading edge network technologies are brought out (GigE a few years ago,
10 GigE now), hosts can't keep up.  Specifically, these people usually
don't care about wasting their man CPU cycles, but rather the fact they
can't get the full rate out of their expensive new NIC.

The reason hosts can't keep up are

  (a) host bus speeds, or (not exclusive)
  (b) the CPU can't handle per-packet processing

In the case of (a), TOE doesn't really help.  In the case of (b), Jeff's
proposed general-purpose offload doesn't help -- you really need a custom
ASIC or maybe FPGA if you hope to beat the host CPU.  Thus I think Jeff's
idea is not likely to fly with this crowd of TOE proponents.

The other (much nicer) solution to case (b) is to just USE A BIGGER MTU.
1500 bytes is ridiculously small.  Even with a 9k MTU, the benefits of TOE
or TSO are nearly vanishing.  Those who say they require high performance,
but are unwilling to buy or produce networking gear with an MTU larger
than 1500 bytes probably deserve what they get.

There are other possible justifications for TOE (with other
counter-arguments) -- basically to reduce load on the main CPU -- but I
think these are for the most part NOT what is driving the market (let me
know if I'm being myopic here).  This issue is also largely or completely
solved by using a bigger MTU.

  -John
