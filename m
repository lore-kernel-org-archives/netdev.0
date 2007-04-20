From: James Morris <jmorris@namei.org>
Subject: FYI: Xen or kernel bug? (fwd)
Date: Fri, 20 Apr 2007 16:39:27 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0704201638500.19208@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:51861 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494AbXDTUja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 16:39:30 -0400
Received: from dsl092-066-197.bos1.dsl.speakeasy.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail1.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 20 Apr 2007 20:39:29 -0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Could be an upstream kernel issue lurking.


---------- Forwarded message ----------
Date: Fri, 20 Apr 2007 22:21:26 +0200
From: Mark Stier <markstier@gmail.com>
To: linux-kernel@vger.kernel.org
Subject: FYI: Xen or kernel bug?

Hello,

tcp_vegas produces division by zero kernel oopses in dom0 when running
a Xen-patched 2.6.16.28 kernel. I have tracked down the problem to
line #256 in tcp_vegas.c: presumably due to flaky Xen timing, the rtt
seems to get zero from time to time (adding 1 to the rtt variable
solves the problem for me). The same should apply to line #140 in
tcp_veno.c, too.

Best regards,
Mark
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
