From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 3 Feb 2014 23:03:23 +0100
Message-ID: <20140203220323.GB17999@order.stressinduktion.org>
References: <52EFFE20.5080500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55602 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbaBCWDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 17:03:24 -0500
Content-Disposition: inline
In-Reply-To: <52EFFE20.5080500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Mon, Feb 03, 2014 at 12:37:52PM -0800, Ben Greear wrote:
> The kernel has some additional patches, but not much to IPv6.
> 
> The bug is that when we have lots of mac-vlans on some ixgbe ports
> (500 per interface in this case), and boot up the system with the ports unplugged,
> we get this crash almost every time.  Boot-up is going to do normal bootup
> stuff plus create and configure the 1000 mac-vlans, dump their routing
> tables, etc.
> 
> We are using one routing table per network device, and some
> ip rules.
> 
> If we plug in the ixgbe ports, we do not ever see a crash.
> 
> We have not yet tried reproducing it on other drivers, but I suspect
> the issue is not related to ixgbe.
> 
> Any ideas on this one?

Could you bring the machine to a panic again with enabling RT6_DEBUG at the
top of ip6_fib.c and send a dump of the trace?

Thanks,

  Hannes
