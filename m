From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [net-2.6.24] forcedeth does not compile without CONFIG_FORCEDETH_NAPI
 set
Date: Fri, 10 Aug 2007 19:34:03 +0200
Message-ID: <46BCA18B.80603@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:36577 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932744AbXHJReh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 13:34:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Checking some other source with the current net-2.6.24 GIT, i just
discovered this:

  CC      drivers/net/mii.o
  CC      drivers/net/Space.o
  CC      drivers/net/loopback.o
  CC      drivers/net/b44.o
  CC      drivers/net/forcedeth.o
drivers/net/forcedeth.c: In function nv_nic_irq:
drivers/net/forcedeth.c:3017: error: RX_WORK_PER_LOOP undeclared (first
use in this function)
drivers/net/forcedeth.c:3017: error: (Each undeclared identifier is
reported only once
drivers/net/forcedeth.c:3017: error: for each function it appears in.)
make[2]: *** [drivers/net/forcedeth.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

This only occurs the CONFIG_FORCEDETH_NAPI is _disabled_.

You definitely know best, how to fix this ;-)

Regards,
Oliver

