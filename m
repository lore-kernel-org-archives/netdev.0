From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Wed, 1 Dec 2004 19:29:43 +0100
Message-ID: <20041201182943.GA14470@xi.wantstofly.org>
References: <16807.20052.569125.686158@robur.slu.se> <1101484740.24742.213.camel@mellia.lipar.polito.it> <41A76085.7000105@draigBrady.com> <1101499285.1079.45.camel@jzny.localdomain> <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain> <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 30, 2004 at 05:09:59PM -0800, Scott Feldman wrote:

> This doubles the kpps numbers for 60-byte packets.  I'd like to see what
> happens on higher bus bandwidth systems.  Anyone?

Dual Xeon 2.4GHz, a 82540EM and a 82541GI both on 32/66 on separate
PCI buses.

BEFORE performance is approx the same for both, ~620kpps.
AFTER performance is ~730kpps, also approx the same for both.

(Note: only sending with one NIC at a time.)

Once or twice it went into a state where it started spitting out these
kinds of messages and never recovered:

	Dec  1 19:13:18 phi kernel: NETDEV WATCHDOG: eth1: transmit timed out
	[...]
	Dec  1 19:13:31 phi kernel: NETDEV WATCHDOG: eth1: transmit timed out
	[...]
	Dec  1 19:13:43 phi kernel: NETDEV WATCHDOG: eth1: transmit timed out

But overall, looks good.  Strange thing that Robert's numbers didn't
improve.  Doing some more measurements right now.


--L
