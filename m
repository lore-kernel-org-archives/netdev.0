From: Kosta Todorovic <kostodo@gmail.com>
Subject: Network card driver problem (znb.o/tulip)
Date: Fri, 11 Mar 2005 05:51:31 +0000
Message-ID: <efe3b00605031021513b7268d1@mail.gmail.com>
Reply-To: Kosta Todorovic <kostodo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My company has recently purchased several ZNYX ZX274 network cards.
These cards are Four Channel, 10/100 PCI Adapters. They use Intel chipsets.

Unfortunately there exists no drivers for linux amd64 architecture.
There are 32bit drivers found at:
http://www.znyx.com/support/drivers/ZX374_drivers.htm but naturally
they wont compile under my amd64 system.

The driver itself is called znb.o and can be downloaded from ZNYX's
website. I spoke to support staff there but they told me they have
discontinued support and development for this series of cards.

The system I am running gentoo and have tried both 2.4.x and 2.6.x
kernels but no luck.

Unfortunately there is NO 64bit drivers available for ANY platform. not even MS.

Does anyone know of a customised znb.o driver built for amd64?
Is there any chance of anyone modifying the source code of the driver
to compile under a amd64 system?

I've noticed that "tulip" drivers get loaded as a module at boot time.
but they dont function correctly. (lets you start the device and
attach ips but cant talk through it)

Is there any variants of the tulip driver that will work for this?

Help much appreciated.


/proc/pci extract for network cards:

  Bus  5, device   5, function  0:
    Ethernet controller: Digital Equipment Corporation DECchip
21142/43 (#30) (rev 65).
      IRQ 30.
      Master Capable.  Latency=128.  Min Gnt=20.Max Lat=40.
      I/O at 0x0 [0x7f].
      Non-prefetchable 32 bit memory at 0xfa1ff400 [0xfa1ff7ff].
  Bus  5, device   4, function  0:
    Ethernet controller: Digital Equipment Corporation DECchip
21142/43 (#29) (rev 65).
      IRQ 29.
      Master Capable.  No bursts.  Min Gnt=20.Max Lat=40.
      I/O at 0x0 [0x7f].
      Non-prefetchable 32 bit memory at 0xf9f00000 [0xf9f003ff].
