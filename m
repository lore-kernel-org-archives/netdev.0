From: "Paul Hernandez" <ph@digitalquake.com>
Subject: RE: NIC on 2.4.19 SMP (mii-diag output)
Date: Mon, 21 Oct 2002 08:16:23 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <FMEDJKFPPLANNCCEABDMCEKLCBAA.ph@digitalquake.com>
References: <3DB1FD1A.4020109@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Linux-net" <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>,
	"Felipe W Damasio" <felipewd@terra.com.br>
In-Reply-To: <3DB1FD1A.4020109@pobox.com>
List-Id: netdev.vger.kernel.org


Jeff and Felipe,

Here is the mii-diag output. Note that this same machine running SuSE 8.0
(2.4.18.SuSE-SMP) worked correctly with this on-board eepro100 LAN.
Unfortunantely I had to move forward to 2.4.19.SuSE-SMP in order to
correct (and did) a problem with 2.4.18 not recognizing the new ide
controller on this new motherboard and it only ran pio mode .IDE  DMA works
fine
now with 2.4.19.SuSE-SMP but LAN fails (with three different vendor
boards) . The second on-board controller is a Promise FastTrack100 RAID
which I also managed to get working on 2.4.18.SuSE-SMP but now fails as
well on 2.4.19 with a bunch of "lost interrupts" messages when it tries to
access drives on it.

Servers me right for buying such a young motherboard.

Thanks for letting me vent a bit.  ;-)

			Paul

linux19:~ # mii-diag -v eth0
mii-diag.c:v2.02 5/21/2001 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
 Basic mode control register 0x3000: Auto-negotiation enabled.
 Basic mode status register 0x7809 ... 7809.
   Link status: not established.
   This transceiver is capable of  100baseTx-FD 100baseTx 10baseT-FD
10baseT.
   Able to perform Auto-negotiation, negotiation not complete.
   End of basic transceiver information.

 MII PHY #1 transceiver registers:
   3000 7809 02a8 0154 05e1 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0001 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0010 0000 0000 0000.
 Basic mode control register 0x3000: Auto-negotiation enabled.
 Basic mode status register 0x7809 ... 7809.
   Link status: not established.
   Capable of  100baseTx-FD 100baseTx 10baseT-FD 10baseT.
   Able to perform Auto-negotiation, negotiation not complete.
 Vendor ID is 00:aa:00:--:--:--, model 21 rev. 4.
   No specific information is known about this transceiver type.
 I'm advertising 05e1: Flow-control 100baseTx-FD 100baseTx 10baseT-FD
10baseT
   Advertising no additional info pages.
   IEEE 802.3 CSMA/CD protocol.
 Link partner capability is 0000:.
   Negotiation did not complete.




-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Saturday, October 19, 2002 5:47 PM
To: Felipe W Damasio
Cc: Paul Hernandez; Linux-net; netdev@oss.sgi.com
Subject: Re: NIC on 2.4.19 SMP


Felipe W Damasio wrote:
> On Fri, 2002-10-18 at 16:57, Paul Hernandez wrote:
>
>>Hello,
>>
>>It was suggested to me that I forward this issue to you both.
>>
>>OS:                                   2.4.19.SuSE  SMP
>>Motherboard:                    Intel Dual P4 Xeon Server board SE7500CW2
>>(latest bios off Intel site)
>>On-borad LAN controller:  Intel 82557/8/9 [Ether Pro 100] (rev 0d)
>>Addional NIC's tried:        3-COM 3C-905C-TX-M, Netgear FA311
>>
>>dmesg output:
>>
>>e100: eth0: Intel(R) 8255x-based Ethernet Adapter
>
>
>>SIOCGMIIPHY on eth0 failed:
>>Operation not supported
>>no MII interfaces found
>
>
> 	Try using the eepro100.c driver from the kernel, and not the one from
> Intel (the driver from the kernel supports SIOCGMIIPHY).
>
> 	Though it does not seem a problem with the driver, you should try using
> the one from the kernel and see if it helps.


I agree that comparison is useful, though it should be pointed out that
ethtool is preferred for e100...

	Jeff



