From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: arp-scan triggers via-velocity "eth0: excessive work at
 interrupt"
Date: Wed, 13 Jun 2007 11:39:58 -0700
Message-ID: <20070613113958.2dc3332f@localhost>
References: <20070613015638.31637.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@horizon.com
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54776 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759887AbXFMSlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 14:41:04 -0400
In-Reply-To: <20070613015638.31637.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12 Jun 2007 21:56:38 -0400
linux@horizon.com wrote:

> It kind of surprised me that sending 254 arp packets by using the arp-scan
> tool (http://www.nta-monitor.com/tools/arp-scan/) on a /24 consistently
> triggers a burst of "eth0: excessive work at interrupt."
> 
> This is a 600 MHz PIII, 2.6.22-rc4, via-velocity driver.
> 
> model name      : Pentium III (Katmai)
> stepping        : 3
> cpu MHz         : 601.406
> cache size      : 512 KB
> 
> 00:09.0 Ethernet controller [0200]: VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter [1106:3119] (rev 11)
> 
> Just double-checking... the program actually sent 463 packets (256 +
> a retry to all those that didn't respond to the first one), and triggers
> 11 copies of the kernel message.
> 
> Command line: arp-scan -I eth0 -l [-v]

The via-velocity needs NAPI among lots of other fixes. The driver is too vendor ish
and nobody works on it.
