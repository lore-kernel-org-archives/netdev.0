From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 14:36:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16712.14153.683690.710955@robur.slu.se>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
	<414808F3.70104@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, Linux NICS <linux.nics@intel.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <414808F3.70104@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


P@draigBrady.com writes:
 > Harald Welte wrote:

 > > I'm currently trying to help Robert Olsson improving the performance of
 > > the Linux in-kernel packet generator (pktgen.c).  At the moment, we seem
 > > to be unable to get more than 760kpps from a single port of a 82546,
 > > (or any other PCI-X MAC supported by e1000) - that's a bit more than 51%
 > > wirespeed at 64byte packet sizes.

 Yes it seems intel adapters work better in BSD as they claim to route
 1 Mpps and we cannot even send more ~750 kpps even with feeding the
 adapter only. :-)

 > In my experience anything around 750Kpps is a PCI limitation,
 > specifically PCI bus arbitration latency. Note the clock speed of
 > the control signal used for bus arbitration has not increased
 > in proportion to the PCI data clock speed.

 Yes data from an Opteron @ 1.6 GHz w. e1000 82546EB 64 byte pkts.

 133 MHz 830 pps
 100 MHz 721 pps
  66 MHz 561 pps

 So higher bus bandwidth could increase the small packet rate.

 So is there a difference in PCI-tuning BSD versus Linux? 
 And even more general can we measure the maximum numbers
 of transactions on a PCI-bus?

 Chip should be able to transfer 64 packets in single burst I don't now
 how set/verify this.

 Cheers.
						--ro
