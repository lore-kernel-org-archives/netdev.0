From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Fri, 8 Oct 2004 00:13:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16741.49048.717774.307462@robur.slu.se>
References: <41633174.7070805@candelatech.com>
	<16740.17875.574967.11417@robur.slu.se>
	<41646587.7070401@candelatech.com>
	<41649425.1010102@candelatech.com>
	<16741.45331.743721.822091@robur.slu.se>
	<4165B981.8060703@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4165B981.8060703@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben Greear writes:

 > You must have several PCI-X busses on that system?  From what I can tell,
 > my dual-xeon system (2.8Ghz, X5DPA-GG motherboard) just can't handle the
 > PCI bandwidth.  I still have processing power it appears, and I see lots
 > of hard-start-xmit errors out of the pro/1000 NICs, so I assume I am
 > able to drive them as hard as they can go...  It may be that receiving
 > the pkts, as I am doing, also decreases transmit in more than a linear fashion.

 Yes the board has 4 different PCI-bus from what I remember it's was a 
 Supermicro X5DL8-GG. Yes you need bus bandwith from what I've seen even 
 133 MHz PCI-X is limiting the small packet performance at GIGE speeds.


 > >  I'm interested if anyone has done any pktgen performance tests with
 > >  w. S2IO or other 10G card we need to upgrade the lab equipment. 
 > >  Both 64 byte pkts and MTU sized pkts is interesting.  Anyone?
 > 
 > Not I, but would be interested as well!

 Andi got one... ;-)

						--ro
