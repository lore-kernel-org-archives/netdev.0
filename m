From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: net-2.6.24 compile breakage: error: 'ipgre_header' undeclared
Date: Thu, 04 Oct 2007 14:49:10 -0700
Message-ID: <47055FD6.5070801@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60559 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757694AbXJDVuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 17:50:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm getting this on net-2.6.24 today:

  CC [M]  net/ipv4/ip_gre.o
net/ipv4/ip_gre.c:1135: error: 'ipgre_header' undeclared here (not in a function)
make[2]: *** [net/ipv4/ip_gre.o] Error 1
make[1]: *** [net/ipv4] Error 2
make[1]: *** Waiting for unfinished jobs....


the git log says sch touched it last:

commit 2c1d70cafc188843ae15a1a504a0a3c9f3c0318d
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Wed Sep 26 22:19:06 2007 -0700

    [NET]: Move hardware header operations out of netdevice.

    Since hardware header operations are part of the protocol class
    not the device instance, make them into a separate object and
    save memory.

    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


anyone seen this? let me know if you want my .config.

PS: No, I didn't touch anything besides e1000e in that tree ;)

Auke
