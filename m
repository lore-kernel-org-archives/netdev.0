From: "Paul Hernandez" <ph@digitalquake.com>
Subject: RE: NIC on 2.4.19 SMP
Date: Mon, 21 Oct 2002 07:20:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <NEBBKAFGCLJCEABADOEOOEJACAAA.ph@digitalquake.com>
References: <3DB1FD1A.4020109@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Paul Hernandez" <ph@digitalquake.com>,
   "Linux-net" <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>,
   "Felipe W Damasio" <felipewd@terra.com.br>
In-Reply-To: <3DB1FD1A.4020109@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff and Felipe,

I naturally tried the default e100 first when I
installed SuSE 8.1 and only tried the eepro100.c
when the e100 failed identically. The e100 is harder
to debug w/o MII so felt the e100pro with MII might
shed some light.

Any suggestions. I'll happily assist in resolving this.

				Paul Hernandez  408-374-8686 x202
				Campbell, CA

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Saturday, October 19, 2002 17:47 PM
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
