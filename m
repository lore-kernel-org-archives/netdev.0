From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m driver v2
Date: Thu, 27 Nov 2008 11:47:17 +0100
Message-ID: <AC362BF0-D9FE-42F5-97DA-754A31446B16@holtmann.org>
References: <cover.1227684995.git.inaky@linux.intel.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:56813 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521AbYK0Kr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 05:47:26 -0500
In-Reply-To: <cover.1227684995.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Inaky,

> This code is broken up in a WiMAX subsystem and a driver for the Intel
> 2400m Wireless WiMAX Link. To be able to fully utilize WiMAX services,
> you need extra pieces of device-specific user space software; for now,
> there is a C level API (the Common API) to use/control it, but a high
> level API over DBUS that should work for any device is in the
> works. See details further below.

this is not a big deal, but a more general question on how the layout  
of the kernel source code tree. So the whole WiMAX subsystem should be  
in net/wimax/, but for the drivers I think using drivers/net/wimax/ is  
wrong. None of these drivers should ever register an Ethernet or  
network device directly. They register themselves with the WiMAX  
subystem. So I would propose to use drivers/wimax/ here. We do the  
same with Bluetooth. All the drivers are under drivers/bluetooth/,  
because they don't register any kind of network device.

Jeff, what is your take on this. Shouldn't be drivers/net/ only  
contain drivers that actually use struct net_device somehow?

Regards

Marcel

