From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [E1000-devel] Transmission limit
Date: Thu, 02 Dec 2004 21:23:30 -0800
Message-ID: <1102051410.3546.45.camel@localhost.localdomain>
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
	 <1101919791.5198.15.camel@localhost.localdomain>
	 <16815.23964.93437.411404@robur.slu.se>
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
In-Reply-To: <16815.23964.93437.411404@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-02 at 10:23, Robert Olsson wrote: 
> It can increase TX performance from 800 kpps to
>   1125128pps 576Mb/sec (576065536bps) errors: 0
>   1124946pps 575Mb/sec (575972352bps) errors: 0

These are the best numbers reported so far, right?

> And some of Scotts may still be used. 

Did you try combining the two?

> +
> +	if( adapter->tx_ring.next_to_use - adapter->tx_ring.next_to_clean > 80 )
> +		e1000_clean_tx_ring(adapter);
> +

You want to use E1000_DESC_UNUSED here because of the ring wrap. ;-)

-scott
