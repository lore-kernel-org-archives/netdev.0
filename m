From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: IPv6 source address selection and privacy extensions
Date: Sat, 26 Feb 2011 23:16:10 +0100
Message-ID: <20110226231610.41c07592@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from legolas.restena.lu ([158.64.1.34]:39096 "EHLO
	legolas.restena.lu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab1BZWZE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 17:25:04 -0500
Received: from legolas.restena.lu (localhost [127.0.0.1])
	by legolas.restena.lu (Postfix) with ESMTP id 984DB9DD06
	for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 23:17:01 +0100 (CET)
Received: from neptune.home (unknown [158.64.15.115])
	by legolas.restena.lu (Postfix) with ESMTP id 747369DD02
	for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 23:17:01 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From Documentation/networking/ip-sysctl.txt:

use_tempaddr - INTEGER
        Preference for Privacy Extensions (RFC3041).
          <= 0 : disable Privacy Extensions
          == 1 : enable Privacy Extensions, but prefer public
                 addresses over temporary addresses.
          >  1 : enable Privacy Extensions and prefer temporary
                 addresses over public addresses.
        Default:  0 (for most devices)
                 -1 (for point-to-point devices and loopback devices)

Is it possible with current kernel to have >1 make temporary addresses
used by default but have manual or dynamic (e.g. MAC based) address used
for some destination addresses/subnets?
If it's possible, how can this be done (adding a hint to ip-sysctl.txt
would then make it easy for others to find)

With IPv4 this can be done via `ip route add $subnet/$prefix src $addr`
though the same does not work for IPv6.

Thanks,
Bruno
