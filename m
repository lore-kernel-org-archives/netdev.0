From: "Paul Hernandez" <ph@digitalquake.com>
Subject: NIC on 2.4.19 SMP
Date: Fri, 18 Oct 2002 09:57:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <FMEDJKFPPLANNCCEABDMAEKGCBAA.ph@digitalquake.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

It was suggested to me that I forward this issue to you both.

OS:                                   2.4.19.SuSE  SMP
Motherboard:                    Intel Dual P4 Xeon Server board SE7500CW2
(latest bios off Intel site)
On-borad LAN controller:  Intel 82557/8/9 [Ether Pro 100] (rev 0d)
Addional NIC's tried:        3-COM 3C-905C-TX-M, Netgear FA311

dmesg output:

e100: eth0: Intel(R) 8255x-based Ethernet Adapter
   Mem:0xfc221000  IRQ:7  Speed:0 Mbps   Dx:N/A
   Failed to detect cable link
   Speed and duplex will be determined at time of connection
   Hardware receive checksums enabled
   cpu cycle saver enabled

All three NIC's worked fine on 2.4.18.SuSE (SuSE 8.0) however I
had to upgrade to correct non-functioning DMA on the on-board
ide controller which now works. (The on-board Promise FastTrack100
RAID controller which also worked on 2.4.18.SuSE now fails with
many "lost interrupts" messages...sigh)

Trying to debug using mii-tool of mii-diag yields:

SIOCGMIIPHY on eth0 failed:
Operation not supported
no MII interfaces found

ifconfig eth0 shows all is fine however cannot ping the gateway with 2.4.19
as can with 2.4.18. I can ping its own ip address fine,

Thanks in advance for any tips.

                                                Paul Hernandez  408-374-8686
x202
                                                Campbell, CA
