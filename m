From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: NIC on 2.4.19 SMP
Date: Sat, 19 Oct 2002 20:47:22 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3DB1FD1A.4020109@pobox.com>
References: <FMEDJKFPPLANNCCEABDMAEKGCBAA.ph@digitalquake.com> <1035064119.2912.31.camel@tank>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Hernandez <ph@digitalquake.com>,
	Linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Felipe W Damasio <felipewd@terra.com.br>
List-Id: netdev.vger.kernel.org

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



