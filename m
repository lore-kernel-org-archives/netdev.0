From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [GIT]: Networking
Date: Mon, 14 Dec 2009 12:53:41 +0100
Message-ID: <200912141253.42017.arnd@arndb.de>
References: <20091205.193505.193701079.davem@davemloft.net> <20091213.202037.229738549.davem@davemloft.net> <d45a3acc0912132026w5ab6b3b3x3f211566779257d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Henner Eisen <eis@baty.hanse.de>
To: andrew hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50472 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757096AbZLNMJb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 07:09:31 -0500
In-Reply-To: <d45a3acc0912132026w5ab6b3b3x3f211566779257d3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 December 2009, andrew hendry wrote:
> Thanks, I didn't know X.25 was actively maintained. I get bounces.
> Is the the maintainers out of date?

>From looking at the posts on the x.25 mailing list and the changes
that went into the kernel during the last three years in that area,
I think it is safe to say that you are now the maintainer ;-).

The last mail on this topic from Henner Eisen was around 2001.

> AX.25 NETWORK LAYER
> M:      Ralf Baechle <ralf@linux-mips.org>
> 
> X.25 NETWORK LAYER
> M:      Henner Eisen <eis@baty.hanse.de>

How about this change?

--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5839,9 +5839,9 @@ F:	sound/soc/codecs/wm8350.c
 F:	sound/soc/codecs/wm8400.c
 
 X.25 NETWORK LAYER
-M:	Henner Eisen <eis@baty.hanse.de>
+M:	Andrew Hendry <andrew.hendry@gmail.com>
 L:	linux-x25@vger.kernel.org
-S:	Maintained
+S:	Odd Fixes
 F:	Documentation/networking/x25*
 F:	include/net/x25*
 F:	net/x25/
