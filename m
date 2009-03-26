From: Marcel Holtmann <marcel@holtmann.org>
Subject: Creating an Ethernet subtype setting
Date: Thu, 26 Mar 2009 13:41:58 +0100
Message-ID: <1238071318.8206.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:47430 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757472AbZC1DFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 23:05:25 -0400
Received: from [192.168.163.172] (S0106001cf062885c.vc.shawcable.net [24.82.150.230])
	by mail.holtmann.org (Postfix) with ESMTP id 0F8C58B45E
	for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 04:05:27 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

so we have more and more subsystem that expose themselves as Ethernet
networking devices and it really becomes hard to identify them in an
easy way. For example WiFi has been an Ethernet device since a long time
now and distinguishing between Ethernet and WiFi is not that hard since
we have the good old WEXT ioctls to identify WiFi devices. However with
WiMAX, Bluetooth, GSM/CDMA modems and even Ethernet bridge devices, it
would be nice to have an easy way to identify them. Since it has become
a mess for laptops that include 4 or more different technologies.

For most of these Ethernet devices, we have to either connect first or
authenticate or do something via a control channel to make them work. So
it would be nice to have an easy way to identify them. I was thinking
about doing this on a per driver or subsystem level and just setting a
subtype value that is Linux specific. We could then expose this via
sysfs and HAL, DeviceKit and udev could use it to annotate these devices
correctly.

Is this is a good idea or totally stupid and should be done better on a
different level?

Regards

Marcel


