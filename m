From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Fri, 3 Dec 2004 00:25:31 +0100
Message-ID: <20041202232531.GA30948@xi.wantstofly.org>
References: <1101499285.1079.45.camel@jzny.localdomain> <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain> <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <16813.58484.343629.570703@robur.slu.se> <1101919791.5198.15.camel@localhost.localdomain> <16815.23964.93437.411404@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@pobox.com, jamal <hadi@cyberus.ca>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16815.23964.93437.411404@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 02, 2004 at 07:23:24PM +0100, Robert Olsson wrote:

> Below is little patch to clean skb at xmit. It's old jungle trick Jamal
> and I used w. tulip. Note we can now even decrease the size of TX ring.
> 
> It can increase TX performance from 800 kpps to
>   1125128pps 576Mb/sec (576065536bps) errors: 0
>   1124946pps 575Mb/sec (575972352bps) errors: 0
> 
> But suffers from scheduling problems as the previous patch. Often we just get
>   582108pps 298Mb/sec (298039296bps) errors: 0

Robert, there is something weird with your setup with packets sizes under
160 bytes.  Can you check if you also get wildly variable numbers on a
baseline kernel perhaps?  The numbers you sent me of packet size vs. pps
were very jumpy as well, even at 10M pkts per run.


--L
