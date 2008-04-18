From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Fri, 18 Apr 2008 16:56:27 +0300
Message-ID: <4808A88B.4010703@teltonika.lt>
References: <200804161428.18066.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804161428.18066.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Hi,
> 
> could you test this patch?
> It does away with the one off serial ioctl replacing it with a standard
> mechanism.
> 
> 	Regards
> 		Oliver

I have tested rfkill and it realy works, but there is two problems:

- LED on the device doesn't indicate rf state... Maybe Filip knows
   some usb command to control it?

- driver creates multiple rfkill entries on sysfs... This is because
   option device has multi endpoints (probe is called twice with GTM380):

T:  Bus=01 Lev=03 Prnt=05 Port=00 Cnt=01 Dev#=  7 Spd=12  MxCh= 0
D:  Ver= 1.10 Cls=ff(vend.) Sub=ff Prot=ff MxPS=64 #Cfgs=  1
P:  Vendor=0af0 ProdID=7211 Rev= 0.00
S:  Manufacturer=Option N.V.
S:  Product=Globetrotter HSUPA Modem
S:  SerialNumber=Serial Number
C:* #Ifs= 2 Cfg#= 1 Atr=80 MxPwr=500mA
I:* If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=ff Driver=hso
E:  Ad=83(I) Atr=02(Bulk) MxPS=  64 Ivl=0ms
E:  Ad=03(O) Atr=02(Bulk) MxPS=  64 Ivl=0ms
E:  Ad=85(I) Atr=03(Int.) MxPS=  16 Ivl=128ms
I:* If#= 1 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=ff Prot=ff Driver=hso
E:  Ad=84(I) Atr=02(Bulk) MxPS=  64 Ivl=0ms
E:  Ad=04(O) Atr=02(Bulk) MxPS=  64 Ivl=0ms

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
