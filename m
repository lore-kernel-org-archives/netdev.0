From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Remove softirq scheduling from pktgen [PATCH]
Date: Mon, 27 Aug 2007 20:22:26 +0200
Message-ID: <18131.5730.626861.397535@robur.slu.se>
References: <18131.623.945573.425948@robur.slu.se>
	<20070827171846.GA2264@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:40318 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751728AbXH0SWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 14:22:30 -0400
In-Reply-To: <20070827171846.GA2264@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Christoph Hellwig writes:

 > > Hello, It's not a job for pktgen.
 > 
 > Please also kill the do_softirq export while you're at it.


 Right seems like pktgen luckily was the only user.

 Cheers
					--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/kernel/softirq.c b/kernel/softirq.c
index 0f546dd..dbbdcd7 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -271,8 +271,6 @@ asmlinkage void do_softirq(void)
 	local_irq_restore(flags);
 }
 
-EXPORT_SYMBOL(do_softirq);
-
 #endif
 
 /*
