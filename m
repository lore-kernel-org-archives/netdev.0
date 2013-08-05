From: Dan Williams <dcbw@redhat.com>
Subject: Re: Alcatel X220S HSDPA modem
Date: Mon, 05 Aug 2013 08:34:44 -0500
Message-ID: <1375709684.5454.2.camel@dcbw.foobar.com>
References: <alpine.LNX.2.02.1308040157360.1079@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46663 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655Ab3HENb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 09:31:26 -0400
In-Reply-To: <alpine.LNX.2.02.1308040157360.1079@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-04 at 01:59 +0200, Enrico Mioso wrote:
> Hello everybody!
> I'm going to investigate a little bit on an obscure Alcatel device - the 
> Alcatel X220s, manifactured by TCT Mobile Phones.
> 
> It supports a NDIS network interface, as you will be able to discover looking 
> at the driver package, still: don't know what's the protocol used.
> At a first glance, I would just like to avoid option.ko binding to non-serial 
> interface as it happens now. So I would appreciate it a lot if you help me 
> distinguish non-serial interfaces from serial ones, looking at this lsusb 
> listing and the driver package (see link below).
> 
> Another strange thing is - the device interface referred as the WAN one is "06"
> but here we ave from 0 to 5 interfaces!
> Looking at this msdn article, it seems Windows does no elaboration regarding 
> the InterfaceNumber field. So - am I missing an interface or does Windows start 
> numbering interfaces from 1?

Some devices expose different USB layouts based on the command that's
sent to them to "switch" them from fake-driver-CD mode to modem mode.
If you're at all able to sniff the modeswitch command maybe we could see
if it's the same one as what usb_modeswitch sends on Linux?

Dan

> Driver package link:
> http://www.gstorm.eu/dgm/alcdrv.tar.xz
> (I simply decompressed the Innosetup installer to let you browse these files 
> with no major issues!)
> 
> Any help and documentation would be greatly apreciated!!
> 
> 
> Bus 001 Device 002: ID 1bbb:0017 T & A Mobile Phones 
> Device Descriptor:
>    bLength                18
>    bDescriptorType         1
>    bcdUSB               2.00
>    bDeviceClass            0 (Defined at Interface level)
>    bDeviceSubClass         0
>    bDeviceProtocol         0
>    bMaxPacketSize0        64
>    idVendor           0x1bbb T & A Mobile Phones
>    idProduct          0x0017
>    bcdDevice            0.00
>    iManufacturer           3 USBModem
>    iProduct                2 HSPA Data Card
>    iSerial                 4 1234567890ABCDEF
>    bNumConfigurations      1
>    Configuration Descriptor:
>      bLength                 9
>      bDescriptorType         2
>      wTotalLength          154
>      bNumInterfaces          6
>      bConfigurationValue     1
>      iConfiguration          1 USBModem Configuration
>      bmAttributes         0xa0
>        (Bus Powered)
>        Remote Wakeup
>      MaxPower              500mA
>      Interface Descriptor:
>        bLength                 9
>        bDescriptorType         4
>        bInterfaceNumber        0
>        bAlternateSetting       0
>        bNumEndpoints           2
>        bInterfaceClass       255 Vendor Specific Class
>        bInterfaceSubClass    255 Vendor Specific Subclass
>        bInterfaceProtocol    255 Vendor Specific Protocol
>        iInterface              0
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x81  EP 1 IN
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x01  EP 1 OUT
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>      Interface Descriptor:
>        bLength                 9
>        bDescriptorType         4
>        bInterfaceNumber        1
>        bAlternateSetting       0
>        bNumEndpoints           2
>        bInterfaceClass       255 Vendor Specific Class
>        bInterfaceSubClass    255 Vendor Specific Subclass
>        bInterfaceProtocol    255 Vendor Specific Protocol
>        iInterface              0
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x82  EP 2 IN
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x02  EP 2 OUT
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>      Interface Descriptor:
>        bLength                 9
>        bDescriptorType         4
>        bInterfaceNumber        2
>        bAlternateSetting       0
>        bNumEndpoints           2
>        bInterfaceClass       255 Vendor Specific Class
>        bInterfaceSubClass    255 Vendor Specific Subclass
>        bInterfaceProtocol    255 Vendor Specific Protocol
>        iInterface              0
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x83  EP 3 IN
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x03  EP 3 OUT
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>      Interface Descriptor:
>        bLength                 9
>        bDescriptorType         4
>        bInterfaceNumber        3
>        bAlternateSetting       0
>        bNumEndpoints           2
>        bInterfaceClass       255 Vendor Specific Class
>        bInterfaceSubClass    255 Vendor Specific Subclass
>        bInterfaceProtocol    255 Vendor Specific Protocol
>        iInterface              0
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x84  EP 4 IN
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x04  EP 4 OUT
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>      Interface Descriptor:
>        bLength                 9
>        bDescriptorType         4
>        bInterfaceNumber        4
>        bAlternateSetting       0
>        bNumEndpoints           2
>        bInterfaceClass         8 Mass Storage
>        bInterfaceSubClass      6 SCSI
>        bInterfaceProtocol     80 Bulk-Only
>        iInterface              0
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x05  EP 5 OUT
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval               0
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x85  EP 5 IN
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval               0
>      Interface Descriptor:
>        bLength                 9
>        bDescriptorType         4
>        bInterfaceNumber        5
>        bAlternateSetting       0
>        bNumEndpoints           3
>        bInterfaceClass       255 Vendor Specific Class
>        bInterfaceSubClass    255 Vendor Specific Subclass
>        bInterfaceProtocol    255 Vendor Specific Protocol
>        iInterface              0
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x86  EP 6 IN
>          bmAttributes            3
>            Transfer Type            Interrupt
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0040  1x 64 bytes
>          bInterval               5
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x87  EP 7 IN
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
>        Endpoint Descriptor:
>          bLength                 7
>          bDescriptorType         5
>          bEndpointAddress     0x06  EP 6 OUT
>          bmAttributes            2
>            Transfer Type            Bulk
>            Synch Type               None
>            Usage Type               Data
>          wMaxPacketSize     0x0200  1x 512 bytes
>          bInterval              32
> Device Qualifier (for other device speed):
>    bLength                10
>    bDescriptorType         6
>    bcdUSB               2.00
>    bDeviceClass            0 (Defined at Interface level)
>    bDeviceSubClass         0
>    bDeviceProtocol         0
>    bMaxPacketSize0        64
>    bNumConfigurations      1
> Device Status:     0x0001
>    Self Powered
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
