From: Marcin Juszkiewicz <marcin@juszkiewicz.com.pl>
Subject: dm9601 as ethX or usbX?
Date: Mon, 20 Apr 2009 14:57:36 +0200
Message-ID: <200904201457.37704.marcin@juszkiewicz.com.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host4.kei.pl ([195.149.226.213]:60798 "EHLO smtp.host4.kei.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755316AbZDTNEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 09:04:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have two dm9601 based adapters. First one is recognized as 'ethX':

[269425.698235] usb 1-5.4.1: new full speed USB device using ehci_hcd and address 16
[269425.788125] usb 1-5.4.1: configuration #1 chosen from 1 choice
[269425.793478] eth1: register 'dm9601' at usb-0000:00:1a.7-5.4.1, Davicom DM9601 USB Ethernet, 00:60:6e:7f:0c:20

But second is 'usbX':

[269530.937166] usb 1-5.3: new full speed USB device using ehci_hcd and address 19
[269531.048917] usb 1-5.3: configuration #1 chosen from 1 choice
[269531.050188] dm9601: No valid MAC address in EEPROM, using 52:9f:f0:e8:44:36
[269531.054054] usb0: register 'dm9601' at usb-0000:00:1a.7-5.3, Davicom DM9601 USB Ethernet, 52:9f:f0:e8:44:36

Both has same vendor/product id:

Bus 001 Device 019: ID 0a46:9601 Davicom Semiconductor, Inc. DM9601 To Fast Ethernet Adapter
Bus 001 Device 018: ID 0a46:9601 Davicom Semiconductor, Inc. DM9601 To Fast Ethernet Adapter

but they differ in details - eth1 one has iManufacturer, iProduct, iSerial 
fields filled, usb0 one has them empty:

  iManufacturer           1 DM9601 USB NNC                                                  
  iProduct                2 Davicom CO., LTD                                                
  iSerial                 3 9601      

Is this normal behaviour of those adapters that ones with empty eeprom
ends as usbX?

I would prefer to have both as ethX as I use them in devices where usbX
as usually usb-gadget (g_ether) and as such usb0 is configured in total 
different scheme. 

I know that one of options would be using udev and renaming of interface 
but then I would have to remember to always copy that rule to each device.

Regards, 
-- 
JID:      hrw@jabber.org
Website:  http://marcin.juszkiewicz.com.pl/
LinkedIn: http://www.linkedin.com/in/marcinjuszkiewicz


