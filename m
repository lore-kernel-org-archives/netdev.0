From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 18:51:25 -0500
Message-ID: <454BD5FD.2030502@pobox.com>
References: <20061103152025.5d27bd8d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51100 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932500AbWKCXva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 18:51:30 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061103152025.5d27bd8d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I am working on getting WOL to work on sky2 (and then skge). But in the process I
> noticed that the semantics of WOL seems to be device dependent. I assume that WOL
> should work when device is suspended. But some drivers also support WOL when
> the device is down (or even removed).

[...]
> It doesn't seem like a good idea for a network device to wake the system
> if it is down. Maybe if the kernel fully supported dormant, maybe, but
> when device is down it shouldn't impact the system.


You seem to be muddling "device", "driver", and "system" together.

The purpose of WOL is being able to turn on a system remotely, if it is 
in a power-off or sleep state.

So, if the system is -on- and the interface is down and/or driver is 
unloaded, are you saying WOL is a problem somehow?

	Jeff




