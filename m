From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] iproute2 2.6.9-041019
Date: Wed, 20 Oct 2004 09:15:54 -0700
Sender: lartc-admin@mailman.ds9a.nl
Message-ID: <20041020091554.57e60936@zqx3.pdx.osdl.net>
References: <41758014.4080502@osdl.org>
	<Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, LARTC@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: Jeff Chua <jeffchua@silk.corp.fedex.com>
In-Reply-To: <Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

Try this, ss was dragging in byteorder.h and it didn't need to.

diff -Nru a/misc/ss.c b/misc/ss.c
--- a/misc/ss.c	2004-10-20 09:13:56 -07:00
+++ b/misc/ss.c	2004-10-20 09:13:56 -07:00
@@ -33,7 +33,6 @@
 #include "libnetlink.h"
 #include "SNAPSHOT.h"
 
-#include <asm/byteorder.h>
 #include <linux/tcp.h>
 #include <linux/tcp_diag.h>
 
_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
