From: Matti Aarnio <matti.aarnio-VYF+RMHuKCpAfugRpC6u6w@public.gmane.org>
Subject: AX.25 devices on USB ?
Date: Wed, 19 Aug 2009 23:41:25 +0300
Message-ID: <20090819204125.GB30210@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-ax25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Linux there is support for special Radio Amateur radio network protocol
called AX.25 (and couple more or less related ones).

My pondering is: What kind of USB device class profile specification to bend
so that I could make a packet oriented radio data modem connectable to these
network layers ?

I do think that it needs to be some sort of "Communications Device Class"
thing, but what kind of ?  I really do not want to put virtual serial ports
and KISS encapsulation in there...  (Those not familar with Radio Amateur
protocols, KISS is variation of SLIP with a hook to handle couple link-layer
control functions, plus multiplexing multiple devices on single serial port.)


On USB CDC specification part 4.7 there is a table of "Data Interface Class
Protocol Codes" -- and there code 31h: "HDLC" would probably be what engineer
orders for all manner of radio amateur data protocols.
(That use packets to begin with.)

This is one of "ISDN device" subclasses, which may cause interesting mixup
when plugged in..


Another could be to bend "CDC ECM" -- to treat the devices as if they are
Ethernet.

Third possibility is to bend the specification called "CDC WMC1.1";
"Wireless Mobile Communications device", which these sort of are...
Pick either "LAN frame", or some "MDLM".


What I would prefer to avoid like a plague is using "this is proprietary"
type tagging.

Any ideas ?

  /Matti Aarnio
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
