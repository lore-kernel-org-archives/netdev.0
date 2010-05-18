From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pegasus: fix USB device ID for ETX-US2
Date: Mon, 17 May 2010 22:42:04 -0700 (PDT)
Message-ID: <20100517.224204.212416818.davem@davemloft.net>
References: <4BF0FC1C.2020408@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tabe@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755485Ab0ERFl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:41:56 -0400
In-Reply-To: <4BF0FC1C.2020408@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tadashi Abe <tabe@mvista.com>
Date: Mon, 17 May 2010 17:19:40 +0900

> USB device ID definition for I-O Data ETX-US2 is wrong.
> Correct ID is 0x093a. Here's snippet from /proc/bus/usb/devices;
> 
> T:  Bus=01 Lev=01 Prnt=01 Port=01 Cnt=01 Dev#=  2 Spd=480 MxCh= 0
> D:  Ver= 2.00 Cls=ff(vend.) Sub=ff Prot=00 MxPS=64 #Cfgs=  1
> P:  Vendor=04bb ProdID=093a Rev= 1.01
> S:  Manufacturer=I-O DATA DEVICE,INC.
> S:  Product=I-O DATA ETX2-US2
> S:  SerialNumber=A26427
> C:* #Ifs= 1 Cfg#= 1 Atr=80 MxPwr=224mA
> I:* If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=00 Driver=pegasus
> E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
> E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
> E:  Ad=83(I) Atr=03(Int.) MxPS=   8 Ivl=125us
> 
> This patch enables pegasus driver to work fine with ETX-US2.
> 
> Signed-off-by: Tadashi Abe <tabe@mvista.com>

Applied, thanks.
