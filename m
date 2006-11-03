From: Stephen Hemminger <shemminger@osdl.org>
Subject: Wake On Lan device semantics
Date: Fri, 3 Nov 2006 15:20:25 -0800
Message-ID: <20061103152025.5d27bd8d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26071 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932490AbWKCXch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 18:32:37 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am working on getting WOL to work on sky2 (and then skge). But in the process I
noticed that the semantics of WOL seems to be device dependent. I assume that WOL
should work when device is suspended. But some drivers also support WOL when
the device is down (or even removed).

Now I know some distro's like Ubuntu take down and then remove every network
device on suspend. That's their problem, if they don't want to use suspend
as intended because they want to handle broken hardware, that's their problem.

It doesn't seem like a good idea for a network device to wake the system
if it is down. Maybe if the kernel fully supported dormant, maybe, but
when device is down it shouldn't impact the system.


-- 
Stephen Hemminger <shemminger@osdl.org>
