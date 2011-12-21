From: eddie@ehuk.net
Subject: usb/mcs7830: Cannot read MAC address
Date: Wed, 21 Dec 2011 20:40:44 +0000
Message-ID: <4EF2444C.1050700@ehuk.net>
Reply-To: eddie@ehuk.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.freestuffjunction.co.uk ([109.169.51.71]:11781 "EHLO
	mail.freestuffjunction.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754023Ab1LUUs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 15:48:56 -0500
Received: from tv.ehuk.net (tv.ehuk.net [10.0.5.25])
	by mail.freestuffjunction.co.uk (8.13.8/8.13.8) with ESMTP id pBLKeivW032255
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 20:40:45 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a USB adapter by Pluscom with a Moschip chip.  Plugging it into a 
Centos 5.7 box with a vanilla 3.1.5 kernel I get:

usb 5-8: new high speed USB device number 4 using ehci_hcd
usb 5-8: New USB device found, idVendor=9710, idProduct=7830
usb 5-8: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 5-8: Product: USB-MAC Controller
usb 5-8: Manufacturer: Moschip Semiconductor
usb 5-8: SerialNumber: 081600e2
usb 5-8: Cannot read MAC address
MOSCHIP usb-ethernet driver: probe of 5-8:1.0 failed with error -110

I don't see this error plugging the device into my Fedora 15 Laptop with 
a very recent kernel, which makes me think this could be something to do 
with Centos' old userspace, maybe the kernel headers or udev.

Can anyone suggest roughly whereabouts the problem might lie so I can 
hunt around for a solution in the right place?

thanks in advance,
Eddie
