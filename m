From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 17:33:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16712.24803.315813.277140@robur.slu.se>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
	<414808F3.70104@draigBrady.com>
	<16712.14153.683690.710955@robur.slu.se>
	<1095256191.1043.17.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        Harald Welte <laforge@netfilter.org>,
        Linux NICS <linux.nics@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095256191.1043.17.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jamal writes:
 > >  Yes data from an Opteron @ 1.6 GHz w. e1000 82546EB 64 byte pkts.
 > >=20
 > >  133 MHz 830 pps
 > >  100 MHz 721 pps
 > >   66 MHz 561 pps

 Well the pps should kpps but everybody seem to understand this.
=20
> BTW, is this per interface? i thought i have seen numbers in the range
 > of 1.3Mpps from you.

 Yes 1.3 Mpps is aggregated forwarding performance from 2 *.1.6 GHz
 Opterons. In a setup where CPU0 handles eth0->eth1 and CPU1 handles
 eth2->eth3.=20

 So due to the fact that a single NIC's TX does not keep up with packet=20
 budget I had to use several "flows" to saturate the packet budget.

 This is a little breakthrough as we for the first time see some=20
 aggregated performance with packet forwarding and got something in
 return for all multiprocessor efforts.

 IMO this is much more important then the last percent of performance
 of pps numbers.

 But the aggregated performance is only seen with Opterons my conclusion
 as we discussed is that memory/controller is local to the CPU and gives=20
 lower latency and additional CPU adds memory controllers. Compare this=20
 to where many CPU's share same controller/memory.


 > What P=E1draig.posted in regards to the MMRBC register is actually
 > enlightening. I kept thinking about it after i sent my last email.
 > If indeed the overhead is incured in the setup(all fingers in my test
 > setups point fingers at this) then increasing the burst size should sh=
ow
 > improvements.

 It's worth to test...

 Cheers.

						--ro
