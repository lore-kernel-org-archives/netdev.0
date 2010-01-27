From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH 00/21] net/atm neatening cleanups
Date: Tue, 26 Jan 2010 21:11:49 -0800
Message-ID: <1264569109.14552.3.camel@Joe-Laptop.home>
References: <cover.1264541547.git.joe@perches.com>
	 <20100126.205757.101473582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1495 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab0A0FLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2010 00:11:51 -0500
In-Reply-To: <20100126.205757.101473582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-26 at 20:57 -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 26 Jan 2010 13:39:59 -0800
> > Miscellaneous cleanups to net/atm
> All looks good.

Unfortunately, appearances aren't necessarily trustworthy.
5/21 is missing a close parenthesis.

+	print_hex_dump(KERN_DEBUG, "br2684: skb: ", DUMP_OFFSET,
+	               16, 1, skb->data, min(NUM2PRINT, skb->len, true);
 #endif

should be:

+	print_hex_dump(KERN_DEBUG, "br2684: skb: ", DUMP_OFFSET,
+	               16, 1, skb->data, min(NUM2PRINT, skb->len), true);
 #endif

Want an updated 5/21 or another patch?

