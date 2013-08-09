From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Fri, 9 Aug 2013 16:19:39 +0200
Message-ID: <20130809141939.GL14001@order.stressinduktion.org>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl> <20130807200637.GD32257@order.stressinduktion.org> <26D8997F-7CDF-425A-B0DC-4D57996871E5@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	equinox@diac24.net, boutier@pps.univ-paris-diderot.fr
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41685 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030569Ab3HIOTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 10:19:41 -0400
Content-Disposition: inline
In-Reply-To: <26D8997F-7CDF-425A-B0DC-4D57996871E5@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 09, 2013 at 04:12:20PM +0200, Teco Boot wrote:
> Double checked, it works. Tested with Common Open Research Emulator (CORE, from NRL).
> 
> === But ===
> 
> I had some problems with CORE. Could be me, new kernel version, the patch, CORE using network namespaces, or combination of that. sudo hangs, reboot hangs, ip address show hangs.
> With ps -ef, I see some suspected items:
> root      4858  4161  0 15:57 ?        00:00:00 /sbin/ip -6 addr flush dev eth0
> root      4859     2  0 15:57 ?        00:00:00 [kworker/0:3]
> In the emulation I use, there was no IPv6.
> 
> I'll try to figure out if it is CORE & netns in combination with patch. Or just the patch. Or just the new kernel.
> Just to speed up, any idea where to look for?

echo t > /proc/sysrq-trigger and check dmesg while the system hangs. Maybe you
have to use a serial console and send the sysrq over keyboard/break.

Greetings,

  Hannes
