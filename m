From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Feb 15 (decnet)
Date: Wed, 15 Feb 2012 16:38:01 -0500 (EST)
Message-ID: <20120215.163801.2243433584488421039.davem@davemloft.net>
References: <20120215160352.60be31b78879628be7e446b8@canb.auug.org.au>
	<4F3C0CE3.6020708@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4F3C0CE3.6020708@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Wed, 15 Feb 2012 11:52:03 -0800

> On 02/14/2012 09:03 PM, Stephen Rothwell wrote:
>> Hi all,
>> 
>> Changes since 20120214:
> 
> 
> on x86_64:
> 
>   CC      net/decnet/dn_nsp_in.o
> In file included from /next/linux-next-20120215/net/decnet/dn_nsp_in.c:75:0:
> /next/linux-next-20120215/include/net/dn.h:195:65: warning: 'struct flowidn' declared inside parameter list

I can't reproduce this in the net-next tree using your config but I can
certainly fix it, as follows :-)

--------------------
decnet: net/dn.h needs net/flow.h

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dn.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index 298521e..814af0b 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -3,6 +3,7 @@
 
 #include <linux/dn.h>
 #include <net/sock.h>
+#include <net/flow.h>
 #include <asm/byteorder.h>
 #include <asm/unaligned.h>
 
-- 
1.7.7.6
