From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: Netpoll checksum issue
Date: Wed, 19 Apr 2006 10:15:57 -0700
Message-ID: <20060419101557.30ac8461@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:718 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751123AbWDSRP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 13:15:59 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 20 Apr 2006 00:22:16 +0800
From: Aubrey <aubreylee@gmail.com>
Newsgroups: linux.dev.kernel
Subject: Netpoll checksum issue


Hi all,
I'm porting my network driver from 2.6.12 to 2.6.16. It almostly work
without any change, except the netpoll mode. When I use kgdb to debug
kernel, gdb client can not establish the connection with gdb server.
Then I digged into the code, and I found in the routine "__netpoll_rx"
in the file "net/core/netpoll.c", the "checksum_udp" call always
failed, but it works on 2.6.12.
Could you please give me some suggestions?
Thanks a lot.

Regards,
-Aubrey
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
