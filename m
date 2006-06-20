From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: rtl8150 usb driver, needs more vendor ids?
Date: Tue, 20 Jun 2006 13:13:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0606201308130.6281@localhost.localdomain>
References: <449799BA.1050303@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: NetDev <netdev@vger.kernel.org>, petkan@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.nucleusys.com ([217.79.38.164]:2185 "EHLO
	zztop.nucleusys.com") by vger.kernel.org with ESMTP id S932548AbWFTKNe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 06:13:34 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <449799BA.1050303@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 	Hi Ben,

What you have sent me is a bit of a puzzle.

Looking at the device's details i can see it is not RTL8150 based device, 
but ADMtek's ADM8511.  Both vendor and device IDs have been listed in 
pegasus.c for a long long time.

Using rtl8150.c will not help at all since it talks to a different device. 
I suggest using pegasus.c ...


 		Petko



On Mon, 19 Jun 2006, Ben Greear wrote:

> Someone put a wired usb-to-ethernet adapter into a system running
> the 2.6.13.5 kernel.  The driver is evidently the rtl8150, and this
> person sent me what appeared to be a modified version of the rtl8150
> that is in the kernel.  The kernel driver does not appear to even attempt
> to use this device.
>
> Here is the output from /proc/bus/usb/devices:
>
> T:  Bus=01 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#=  4 Spd=12  MxCh= 0
> D:  Ver= 1.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS= 8 #Cfgs=  1
> P:  Vendor=07a6 ProdID=8511 Rev= 1.01
> S:  Manufacturer=ADMtek
> S:  Product=USB To LAN Converter
> S:  SerialNumber=0001
> C:* #Ifs= 1 Cfg#= 1 Atr=a0 MxPwr=160mA
> I:  If#= 0 Alt= 0 #EPs= 3 Cls=00(>ifc ) Sub=00 Prot=00 Driver=(none)
> E:  Ad=81(I) Atr=02(Bulk) MxPS=  64 Ivl=0ms
> E:  Ad=02(O) Atr=02(Bulk) MxPS=  64 Ivl=0ms
> E:  Ad=83(I) Atr=03(Int.) MxPS=   8 Ivl=1ms
>
> The vendor driver (GPL) I received is available here:
> http://www.candelatech.com/oss/RTL8150.C
>
> When I get a chance later this week, I plan to add this vendor id
> and see if it works.  Since the physical equipment is half a world
> away, I'd welcome any conjecture as to whether simply adding the
> device ID will work or not...
>
> Thanks,
> Ben
>
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
>
