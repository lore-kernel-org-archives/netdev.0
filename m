From: "Paul Hernandez" <ph@digitalquake.com>
Subject: RE: NIC on 2.4.19 SMP
Date: Mon, 21 Oct 2002 07:21:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <NEBBKAFGCLJCEABADOEOCEJBCAAA.ph@digitalquake.com>
References: <1035064119.2912.31.camel@tank>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Linux-net" <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Felipe W Damasio" <felipewd@terra.com.br>
In-Reply-To: <1035064119.2912.31.camel@tank>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, I'll send the MII-diag output when I get into
work in about an hour.

			Paul

-----Original Message-----
From: Felipe W Damasio [mailto:felipewd@terra.com.br]
Sent: Saturday, October 19, 2002 14:49 PM
To: Paul Hernandez
Cc: Linux-net; netdev@oss.sgi.com
Subject: Re: NIC on 2.4.19 SMP


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
