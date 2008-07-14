From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 18:43:00 +0300
Message-ID: <200807141843.00845.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1513 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754372AbYGNPpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 11:45:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi everybody,

In our Linux port we added a new sk_buff member, hwstamp, to store a hardware 
generated timestamp for received packets. The hardware can also insert  
hardware timestamps in the payload on the TX path and can have the RX / TX 
clocks synchronized. We use this infrastructure to compute one-way delays 
with high precision (20ns resolution).

I know that adding new members to such heavily used structures like the skb is 
viewed harshly - especially for such exotic cases as the one described above. 
So, would such a patch be considered for inclusion? Or maybe there is a 
better way of doing the above?

Thanks,
tavi
