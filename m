From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 2.6] e100: remove reference to NAPI config option
Date: Tue, 1 Feb 2005 12:43:58 +1100
Message-ID: <20050201014358.GD15786@krispykreme.ozlabs.ibm.com>
References: <1107220952.3366.4.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, lunz@falooley.org
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1107220952.3366.4.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Scott,

> e100 is NAPI all the time, so the Kconfig option is wasting space.

Speaking of NAPI...

We have seen issues with NAPI on ppc64 on various cards in the past.
Its possibly due to missing memory barriers; the interrupt and read of
the interrupt status provide syncronization with DMA on the non NAPI
case. Without this you need to be very careful to order reads (eg
between reading the ring status and the packet data).

Anton
