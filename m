From: =?UTF-8?B?SsOpcsO0bWUgUG91bGlu?= <jeromepoulin@gmail.com>
Subject: New ASIX USB3 product
Date: Mon, 19 Nov 2012 14:02:10 -0500
Message-ID: <CALJXSJp+m7FewpW2i6wJoFAN0oGwao4-KjWuUX0F_dcE5vsoPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:49930 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab2KSTCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:02:11 -0500
Received: by mail-qa0-f46.google.com with SMTP id c11so210329qad.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 11:02:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just bought a gigabit ethernet USB3 adapter, it is a StarTech
USB31000S adapter and it does not seem to be un ASIX product database
yet.

I tried binding it with the driver and it returns error -32, what does
this mean?

Here is the dmesg output:
[214792.189316] usb 3-1: new SuperSpeed USB device number 11 using xhci_hcd
[214792.207219] usb 3-1: Parent hub missing LPM exit latency info.
Power management will be impacted.
[214792.211922] usb 3-1: New USB device found, idVendor=0b95, idProduct=1790
[214792.211941] usb 3-1: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[214792.211944] usb 3-1: Product: AX88179
[214792.211948] usb 3-1: Manufacturer: ASIX Elec. Corp.
[214792.211951] usb 3-1: SerialNumber: <12 digits...>
[214792.216865] asix: probe of 3-1:1.0 failed with error -32

Here is lsusb output:
Bus 003 Device 012: ID 0b95:1790 ASIX Electronics Corp.
Couldn't open device, some information will be missing
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               3.00
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol         0
  bMaxPacketSize0         9
  idVendor           0x0b95 ASIX Electronics Corp.
  idProduct          0x1790
  bcdDevice            1.00
  iManufacturer           1
  iProduct                2
  iSerial                 3
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           57
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0
    bmAttributes         0xa0
      (Bus Powered)
      Remote Wakeup
    MaxPower              124mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass    255 Vendor Specific Subclass
      bInterfaceProtocol      0
      iInterface              4
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval              11
        bMaxBurst               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x82  EP 2 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0400  1x 1024 bytes
        bInterval               0
        bMaxBurst               3
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0400  1x 1024 bytes
        bInterval               0
        bMaxBurst              15

And
T:  Bus=03 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#= 12 Spd=5000 MxCh= 0
D:  Ver= 3.00 Cls=ff(vend.) Sub=ff Prot=00 MxPS= 9 #Cfgs=  1
P:  Vendor=0b95 ProdID=1790 Rev=01.00
S:  Manufacturer=ASIX Elec. Corp.
S:  Product=AX88179
S:  SerialNumber=0000249B0438C8
C:  #Ifs= 1 Cfg#= 1 Atr=a0 MxPwr=124mA
I:  If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=00 Driver=(none)
