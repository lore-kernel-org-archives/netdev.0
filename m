From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] isdn: eicon: fix old-style declarations
Date: Thu, 16 Jun 2016 22:06:43 -0700 (PDT)
Message-ID: <20160616.220643.1892766318380339468.davem@davemloft.net>
References: <20160616135020.3154461-1-arnd@arndb.de>
	<20160616135245.3198419-1-arnd@arndb.de>
	<20160616135245.3198419-5-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de, mac@melware.de,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616135245.3198419-5-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 16 Jun 2016 15:52:12 +0200

> Modern C standards expect the '__inline__' keyword to come before the return
> type in a declaration, and we get many warnings for this with "make W=1"
> because the eicon driver has this in a header file:
> 
> eicon/divasmain.c:448:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> eicon/divasmain.c:453:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> eicon/divasmain.c:458:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> eicon/divasmain.c:463:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> eicon/divasmain.c:468:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> eicon/divasmain.c:473:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> eicon/platform.h:274:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> eicon/platform.h:280:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> 
> A similar warning gets printed for the diva_os_register_io_port()
> declaration, because 'register' is interpreted as a keyword instead
> of a variable name:
> 
> In file included from eicon/diva_didd.c:21:0:
> eicon/platform.h:206:1: error: 'register' is not at beginning of declaration [-Werror=old-style-declaration]
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
