From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 8 Apr 2008 21:44:55 +0200
Message-ID: <FA91A8B7-CD77-439F-94EA-AC2742583E89@holtmann.org>
References: <200804011107.38563.inaky@linux.intel.com> <20080408135601.5dad3566@speedy>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Inaky Perez-Gonzalez <inaky@linux.intel.com>, wimax@linuxwimax.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:51997 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbYDHTpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 15:45:00 -0400
In-Reply-To: <20080408135601.5dad3566@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

> This is the short (not in depth) code review of kernel component of  
> Wimax.

many thanks for having a look at the source code.

> Generic stack: drivers/net/wimax

<snip>

> 5. Stack is using generic netlink instead use newer netlink interface
>   for management of devices: newlink/dellink instead see macvlan

I might have missed something in the latest code, but how it is using  
generic netlink for device management. The current code is using  
generic netlink for communication with the user space component. This  
includes task like scanning and association. The current kernel/user  
space API might need improvement, but I am not getting your point  
here. Please explain what you mean.

> i2400m hardware driver

<snip>

> 9. Anyway to reuse existing usbnet infrastructure?

I don't think so. WiMAX is not emulating an Ethernet device. It is an  
IP only networking interface.

> 10. Since device is USB, Rx is in workqueue, so no need to go through
>    netif_rx() softirq, should be able to go through netif_receive_skb

You could have SDIO or PCI as a different transport.

> 12. Since this is new code elminate all legacy ifdef's

Don't worry. We will do this before submitting it for mainline  
inclusion. It is a temporary solutions to help people that wanna test  
it with older kernels.

Regards

Marcel

