From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 17:41:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16712.25270.406341.584928@robur.slu.se>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
	<414808F3.70104@draigBrady.com>
	<16712.14153.683690.710955@robur.slu.se>
	<41484AC2.8090408@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Harald Welte <laforge@netfilter.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <41484AC2.8090408@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


P@draigBrady.com writes:

 > So I'm guessing that increasing the PCI-X burst size setting
 > (MMRBC) will automatically get more packets sent per transfer?
 > I said previously in this thread to google for setpci and MMRBC,
 > but what I know about it is...
 > 
 > To return the current setting(s):
 > 
 > setpci -d 8086:1010 e6.b
 > 
 > The MMRBC is the upper two bits of the lower nibble, where:
 > 
 > 0 = 512 byte bursts
 > 1 = 1024 byte bursts
 > 2 = 2048 byte bursts
 > 3 = 4096 byte bursts
 > 
 > For me to set 4KiB bursts I do:
 > 
 > setpci -d 8086:1010 e6.b=0e

 Thanks!
 That should definitely be tested. Four runs w. pktgen should be enough.

						--ro
