From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] iproute2 2.6.9-041019
Date: Wed, 20 Oct 2004 09:18:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020091846.5151604e@zqx3.pdx.osdl.net>
References: <41758014.4080502@osdl.org>
	<Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, LARTC@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Chua <jeffchua@silk.corp.fedex.com>
In-Reply-To: <Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Similar problem to ss in iptunnel. It was including asm/byteorder.h
a kernel header that it didn't need to.

diff -Nru a/ip/iptunnel.c b/ip/iptunnel.c
--- a/ip/iptunnel.c	2004-10-20 09:18:36 -07:00
+++ b/ip/iptunnel.c	2004-10-20 09:18:36 -07:00
@@ -26,7 +26,6 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <sys/ioctl.h>
-#include <asm/byteorder.h>
 #include <linux/if.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
