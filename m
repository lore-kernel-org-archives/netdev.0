From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/7] myri10ge updates
Date: Mon, 11 Dec 2006 11:23:46 +0100
Message-ID: <457D31B2.30505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:42154 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762753AbWLKKYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 05:24:20 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

The following 7 patches update/fix myri10ge:
1. indentation cleanups
2. add page-based skb routines
3. switch to page-based skb
4. drop contiguous skb routines
5. full vlan frame in small_bytes
6. fix big_bytes in case of vlan frames
7. update driver version to 1.1.0

#1 is independent, while #2-#7 should be applied in order.

#2-#4 contains the physical page based skb conversion splitted in 3 patches
to make it very easy to review.

All these patches have been updated to match the annotations that got
committed last week.

Please apply.

Thanks,
Brice

