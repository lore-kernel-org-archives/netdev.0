From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Sun, 28 Mar 2010 14:38:38 +0400
Message-ID: <4BAF31AE.8070204@ru.mvista.com>
References: <1269652919.30630.1.camel@Linuxdev3>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1269652919.30630.1.camel@Linuxdev3>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

Elina Pasheva wrote:

> Subject: [ANNOUNCEMENT] NET: usb: sierra_net.c driver
> From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
>
> The following is a new Linux driver which exposes certain models of Sierra
> Wireless modems to the operating system as Network Interface Cards (NICs).
>
> This driver requires a version of the sierra.c driver which supports
> blacklisting to work properly. The blacklist in sierra.c rejects the interfaces
> claimed by sierra_net.c. Likewise, the sierra_net.c driver only accepts
> (i.e. whitelists) the interface(s) used for Direct IP traffic.
> The term "Direct IP" is used within Sierra Wireless to refer to these alternate
> data interfaces. The version of sierra.c which supports blacklisting is
> available from the sierra wireless knowledge base page for older kernels. It is
> also available in Linux kernel starting from version 2.6.31.
>
> This driver works with all Sierra Wireless devices configured with PID=68A3
> like USB305, USB306 provided the corresponding firmware version is I2.0
> (for USB305) or M3.0 (for USB306) and later.
> This driver will not work with earlier firmware versions than the ones shown
> above. In this case the driver will issue an error message indicating 
> incompatibility and will not serve the device's DirectIP interface.
>
> Sierra_net.c sits atop a pre-existing Linux driver called usbnet.c.
> A series of hook functions are provided in sierra_net.c which are called by
> usbnet.c in response to a particular condition such as receipt or transmission
> of a data packet. As such, usbnet.c does most of the work of making
> a modem appear to the system as a network device and for properly exchanging
> traffic between the USB subsystem and the Network card interface.
> Sierra_net.c is concerned with managing the data exchanged between the
> so-called Direct-IP interface and the upper layers of the operating system.
>
> The version number of sierra_net.c driver is set to 2.0.
> This patch has been tested on the latest stable kernel-2.6.33.1.
> Signed-off-by: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
> Signed-off-by: Rory Filer <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
>   

   I doubt that it's Rory's email address. :-)

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
