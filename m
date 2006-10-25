From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/1] myri10ge: use physical pages for skb allocation
Date: Wed, 25 Oct 2006 15:28:19 +0200
Message-ID: <453F6673.2040002@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:64211 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S965212AbWJYN3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 09:29:07 -0400
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch reworks the myri10ge driver to use physical pages for skb allocation. A similar patch has been submitted about a month ago within our LRO patches. The LRO code won't be sent here since we are waiting for the core stack to implement a generic LRO.

Please consider this single patch for 2.6.20.

As explained previously, the complete driver code in our CVS also supports high-order allocations instead of single physical pages since it significantly increase the performance. But, since high-order allocations are generally considered a bad idea, we do not include the relevant code in the following patch for inclusion in Linux. Here, we simply pass order=0 to all page allocation routines.

Thanks,
Brice


