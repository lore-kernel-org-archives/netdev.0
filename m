From: Don Fry <brazilnut@us.ibm.com>
Subject: Ethernet MAC address question
Date: Mon, 14 Jun 2004 15:02:36 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406142202.i5EM2bh19464@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When and/or why would an ethernet driver not use the MAC address from
the PROM associated with the adapter?

Since the MAC address can be specified via "ifconfig ethN ether ...."
why not use the PROM value, and override it later if needed?

I have received several complaints that the pcnet32 adapter is using
the 'wrong' MAC address.  By looking back through older kernels, the
pcnet32 code was changed between November 2001 and February 2002 to
read the MAC address from PROM, but to use whatever value was read
from some volatile chip registers, which early chip versions do not
even initialize.

It seems to me the driver should always use the PROM address, assuming
it has one.  What am I missing?

-- 
Don Fry
brazilnut@us.ibm.com
