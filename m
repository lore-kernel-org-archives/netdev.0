From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [E1000-devel] Transmission limit
Date: Thu, 2 Dec 2004 18:54:32 +0100
Message-ID: <16815.22232.190929.306486@robur.slu.se>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	<41A73826.3000109@draigBrady.com>
	<16807.20052.569125.686158@robur.slu.se>
	<1101484740.24742.213.camel@mellia.lipar.polito.it>
	<41A76085.7000105@draigBrady.com>
	<1101499285.1079.45.camel@jzny.localdomain>
	<16811.8052.678955.795327@robur.slu.se>
	<1101821501.1043.43.camel@jzny.localdomain>
	<20041130134600.GA31515@xi.wantstofly.org>
	<1101824754.1044.126.camel@jzny.localdomain>
	<20041201001107.GE4203@xi.wantstofly.org>
	<1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	<16813.58484.343629.570703@robur.slu.se>
	<1101919791.5198.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Lennert Buytenhek <buytenh@wantstofly.org>, jamal <hadi@cyberus.ca>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1101919791.5198.15.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Scott Feldman writes:
 > Thank you Robert for trying it out.

 Scott! 

 I've rerun some of the tests. I've set maxcpus=1 make sure all things
 happens on one CPU. Some HW as yesterday.

 I see a now lot variation in the results from your patch.

 vanilla 
   804353pps 411Mb/sec (411828736bps) errors: 98877

 patch TXD=4096
 Sometimes:   882362pps 451Mb/sec (451769344bps) errors: 0

 patch TXD=2048
 Sometimes:   943007pps 482Mb/sec (482819584bps) errors: 0

 But very often runs around 500 kpps with patch. This smells scheduling to me 
 as smaller rings use to mean higher performance but ring need to big 
 enough to hide latencies.

 See also my next mail...

						--ro
