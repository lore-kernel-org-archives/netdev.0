From: Marc MERLIN <marc@merlins.org>
Subject: Re: Getting the correct asix AX88178 usb gige driver in mainline?
Date: Thu, 7 Jul 2011 10:23:50 -0700
Message-ID: <20110707172350.GD13683@merlins.org>
References: <E1Qes7I-0004Rx-88@myth-lvr.svh.merlins.org> <20110629033025.GA32153@merlins.org> <201107062209.05794.arnd@arndb.de> <20110706210857.GH22090@merlins.org> <201107071455.36975.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, greg@kroah.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:36609 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755125Ab1GGRX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 13:23:56 -0400
Content-Disposition: inline
In-Reply-To: <E1Qes7I-0004Rx-88@myth-lvr.svh.merlins.org> <201107071455.36975.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2011 at 02:55:36PM +0200, Arnd Bergmann wrote:
> On Wednesday 06 July 2011, Marc MERLIN wrote:
> > > The patch I mentioned was merged back in 2006, for 2.6.19. Either that
> > > patch was never complete and is missing support for your hardware, or
> > > it broke since then. You should probably try an old kernel to see if it's
> > > actually a regression.
> > 
> > Thanks for the details Arnd, I'll see if I can boot 2.6.19 on that laptop
> > and report back.
> 
> I would perhaps try something less ancient first, 2.6.27-longterm would be
> a good candidate. If it was working at some point but broken later, chances
> are that it wasn't broken until a few years ago, rather than shortly after
> it was merged.

So, it was problematic to build and boot old kernels for that system, but I
tried my USB adapter in older systems with older kernels.

2.6.20 and 2.6.22.1 both were able to bring the interface up and DHCP.
2.6.24.3 was NOT able to.
Neither was 2.6.34.1.

Mind you, those were not exactly the same kernels with the compile options
on the same machine, but those were the tests I was reasonably able to do
for now.




Linux polgara.svh.merlins.org 2.6.20-16-generic #2 SMP Thu Jun 7 20:19:32 UTC 2007 i686 GNU/Linux
usb 1-5: new high speed USB device using ehci_hcd and address 3
usb 1-5: configuration #1 chosen from 1 choice
eth0: register 'asix' at usb-0000:00:1a.7-5, ASIX AX88178 USB 2.0 Ethernet, 00:0e:c6:88:7c:ae
usbcore: registered new interface driver asix
eth2: link down
ADDRCONF(NETDEV_UP): eth2: link is not ready
ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
eth2: link up, 1000Mbps, full-duplex, lpa 0xC5E1
eth2: no IPv6 routers present
eth1: no IPv6 routers present
-> OK


2.6.22.1-libata-tj-20070803-p4smp-preempt-1khz-marc4
eth0: register 'asix' at usb-0000:00:1a.7-5, ASIX AX88178 USB 2.0 Ethernet, 00:0e:c6:88:7c:ae
usbcore: registered new interface driver asix
eth2: link down
ADDRCONF(NETDEV_UP): eth2: link is not ready
ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
eth2: link up, 1000Mbps, full-duplex, lpa 0xC5E1
eth2: no IPv6 routers present
eth1: no IPv6 routers present
-> OK


2.6.24.3-slub-k8up-preempt-noticks-marc1 (different machine)
usb 1-4: new high speed USB device using ehci_hcd and address 4
usb 1-4: configuration #1 chosen from 1 choice
eth1: register 'asix' at usb-0000:00:02.2-4, ASIX AX88178 USB 2.0 Ethernet, 00:0e:c6:88:7c:ae
usbcore: registered new interface driver asix
udev: renamed network interface eth1 to eth3
eth3: link up, 1000Mbps, full-duplex, lpa 0xCDE1
eth3: link up, 1000Mbps, full-duplex, lpa 0xCDE1
eth3: no IPv6 routers present
-> NOT OK
 
Linux polgara.svh.merlins.org 2.6.34.1-core2smp-1khznohz-preempt-notcks-noide-hm64-20100724 #2 SMP Sat Jul 24 16:02:09 PDT 2010 i686 GNU/Linux
usb 1-5: new high speed USB device using ehci_hcd and address 4
usb 1-5: New USB device found, idVendor=0b95, idProduct=1780
usb 1-5: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 1-5: Product: AX88178 
usb 1-5: Manufacturer: ASIX Elec. Corp.
usb 1-5: SerialNumber: 000002
asix 1-5:1.0: eth1: register 'asix' at usb-0000:00:1a.7-5, ASIX AX88178 USB
2.0 Ethernet, 00:0e:c6:88:7c:ae
usbcore: registered new interface driver asix
eth1: link down
ADDRCONF(NETDEV_UP): eth1: link is not ready
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
eth1: link up, 1000Mbps, full-duplex, lpa 0xC5E1
eth1: no IPv6 routers present
->  NOT OK

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
