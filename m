From: Amit Uttamchandani <amit.uttam@gmail.com>
Subject: Device only sends out one packet. Problem with netif queues?
Date: Fri, 29 Jan 2010 01:00:45 -0800
Message-ID: <20100129090045.GA4126@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f193.google.com ([209.85.210.193]:37598 "EHLO
	mail-yx0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab0A2JAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 04:00:50 -0500
Received: by yxe31 with SMTP id 31so1597198yxe.21
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 01:00:50 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've been modifying drivers/net/ethoc.c for my specific application.

At this point, I get one packet to come out of the device (A DHCP
packet since udhcpc is started on boot). However, after that no other
packets are being sent out.

Could this be a problem in the way I've set up the queues? Or is there
another area in the code I should look at (e.g. napi stuff, phy
related, etc)?

This could be because I am not getting a 'transmit done' interrupt from my
hardware which I am still trying to fix. But I thought it should still
be sending out the packets right? Even though it doesn't receive an ack
from hardware?

Thanks for any help.
