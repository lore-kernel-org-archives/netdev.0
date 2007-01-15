From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: sky2: transmit timed out...
Date: Mon, 15 Jan 2007 17:03:47 +0000
Message-ID: <6278d2220701150903i23be8327if102006b3cee0f2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:32845 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbXAORDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 12:03:52 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1404352uga
        for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 09:03:50 -0800 (PST)
To: "Stephen Hemminger" <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

After some days of uptime, I've been seeing 'transmit timed out'
messages [1]. Let me know if there is any useful debugging you'd like.

--- [1]

sky2 v1.10 addr 0xdfb00000 irq 16 Yukon-EC (0xb6) rev 1
sky2 eth1: addr 00:03:2d:05:9c:27
sky2 lan0: enabling interface
sky2 lan0: Link is up at 1000 Mbps, full duplex, flow control both
[snip]
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 464 .. 441 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 441 report=466 done=466
sky2 hardware hung? flushing
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 441 .. 418 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 443 report=466 done=466
sky2 hardware hung? flushing
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 443 .. 420 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 443 report=466 done=466
sky2 hardware hung? flushing
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 443 .. 420 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 443 report=466 done=466
sky2 hardware hung? flushing
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 443 .. 420 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 443 report=466 done=466
sky2 hardware hung? flushing
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 443 .. 420 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 443 report=466 done=466
sky2 hardware hung? flushing
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 443 .. 420 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 443 report=466 done=466
sky2 hardware hung? flushing
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 443 .. 420 report=466 done=466
sky2 status report lost?
NETDEV WATCHDOG: lan0: transmit timed out
sky2 lan0: tx timeout
sky2 lan0: transmit ring 466 .. 443 report=466 done=466
sky2 hardware hung? flushing

-- 
Daniel J Blueman
