From: Felipe W Damasio <felipewd@terra.com.br>
Subject: Re: NIC on 2.4.19 SMP
Date: 19 Oct 2002 21:48:39 +0000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1035064119.2912.31.camel@tank>
References: <FMEDJKFPPLANNCCEABDMAEKGCBAA.ph@digitalquake.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Paul Hernandez <ph@digitalquake.com>
In-Reply-To: <FMEDJKFPPLANNCCEABDMAEKGCBAA.ph@digitalquake.com>
List-Id: netdev.vger.kernel.org

On Fri, 2002-10-18 at 16:57, Paul Hernandez wrote:
> Hello,
> 
> It was suggested to me that I forward this issue to you both.
> 
> OS:                                   2.4.19.SuSE  SMP
> Motherboard:                    Intel Dual P4 Xeon Server board SE7500CW2
> (latest bios off Intel site)
> On-borad LAN controller:  Intel 82557/8/9 [Ether Pro 100] (rev 0d)
> Addional NIC's tried:        3-COM 3C-905C-TX-M, Netgear FA311
> 
> dmesg output:
> 
> e100: eth0: Intel(R) 8255x-based Ethernet Adapter

> SIOCGMIIPHY on eth0 failed:
> Operation not supported
> no MII interfaces found

	Try using the eepro100.c driver from the kernel, and not the one from
Intel (the driver from the kernel supports SIOCGMIIPHY).

	Though it does not seem a problem with the driver, you should try using
the one from the kernel and see if it helps.

	If it doesn't, reply this mail with the mii-diag output (and driver
version).

Felipe

