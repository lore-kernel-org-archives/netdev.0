From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [E1000-devel] Transmission limit
Date: Wed, 01 Dec 2004 08:49:51 -0800
Message-ID: <1101919791.5198.15.camel@localhost.localdomain>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com> <16807.20052.569125.686158@robur.slu.se>
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
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, jamal <hadi@cyberus.ca>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16813.58484.343629.570703@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-01 at 07:34, Robert Olsson wrote:
> Nice but I no improvements w. 82546GB @ 133 MHz on 1.6 GHz Opteron it seems.
> SMP kernel linux-2.6.9-rc2
> 
> Vanilla. 
>   801077pps 410Mb/sec (410151424bps) errors: 95596
> 
> Patch TXD=4096
>   608690pps 311Mb/sec (311649280bps) errors: 0

Thank you Robert for trying it out.

Well those results are counter-intuitive!  We remove Tx interrupts and
Tx descriptor DMA write-backs and get no re-tries, and performance
drops?  The only bus activities left are the DMA of buffers to device
and the register writes to increment tail.  I'm stumped.  I'll need to
get my hands on a faster system.  Maybe there is a bus analyzer under
the tree.  :-)

-scott
