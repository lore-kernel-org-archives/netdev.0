From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Re: [PATCH] 2.4.20-pre sundance.c cleanups
Date: Wed, 18 Sep 2002 21:53:05 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209190353.g8J3r5q28456@vindaloo.ras.ucalgary.ca>
References: <20020828185612.GA14342@reflexsecurity.com>
	<20020828231333.GA15183@reflexsecurity.com>
Cc: netdev@oss.sgi.com, becker@scyld.com, jgarzik@mandrakesoft.com,
   "Patrick R. McManus" <mcmanus@ducksong.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@gtf.org>
In-Reply-To: <20020828231333.GA15183@reflexsecurity.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  Hi, all. I've just taken the patch Jason released on 28-AUG and
applied it to 2.4.19. The driver finds my D-Link 580-TX 4-port
ethercard, and it seems to be running OK. However, I note a few warts:

- the driver is reporting 10 Mbps rather than 100 Mbps. I've actually
  measured eth0 and eth2 and these are delivering 100 Mbps

- I tried to force eth1 to 100 Mbps FD, but I don't know for sure if
  it's working or not (the switch that eth1 connects to doesn't do
  autoneg properly, but that network sucks, so it's hard to find the
  right machine for bandwidth testing). The kernel doesn't report that
  the interface speed was hard-wired. I'm using this in modules.conf: 
  options         sundance        media="autosense","100mbps_fd","autosense"

I've appended the driver output below.

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
===============================================================================
sundance.c:v1.01d 28-Aug-2002  Written by Donald Becker
  http://www.scyld.com/network/sundance.html
eth0: D-Link DFE-580TX 4 port Server Adapter at 0xc000, 00:05:5d:10:4d:b8, IRQ 5.
eth0: MII PHY found at address 0, status 0x782d advertising 01e1.
eth0: MII PHY found at address 1, status 0x782d advertising 01e1.
eth1: D-Link DFE-580TX 4 port Server Adapter at 0xc400, 00:05:5d:10:4d:b9, IRQ 12.
eth1: MII PHY found at address 0, status 0x782d advertising 01e1.
eth1: MII PHY found at address 1, status 0x782d advertising 01e1.
eth2: D-Link DFE-580TX 4 port Server Adapter at 0xc800, 00:05:5d:10:4d:ba, IRQ 10.
eth2: MII PHY found at address 0, status 0x782d advertising 01e1.
eth2: MII PHY found at address 1, status 0x782d advertising 01e1.
eth3: D-Link DFE-580TX 4 port Server Adapter at 0xcc00, 00:05:5d:10:4d:bb, IRQ 11.
eth3: MII PHY found at address 0, status 0x7809 advertising 01e1.
eth3: MII PHY found at address 1, status 0x7809 advertising 01e1.
eth0: Link changed: Autonegotiation advertising 10Mbps full duplex, partner 10Mbps full duplex.
eth0: Setting full-duplex based on MII #0 negotiated capability 01e1.
eth1: Link changed: Autonegotiation advertising 10Mbps full duplex, partner 10Mbps full duplex.
eth1: Setting full-duplex based on MII #0 negotiated capability 0100.
eth2: Link changed: Autonegotiation advertising 10Mbps full duplex, partner 10Mbps full duplex.
eth2: Setting full-duplex based on MII #0 negotiated capability 01e1.
