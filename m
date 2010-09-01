From: Aaron Williams <awilliams@atheros.com>
Subject: skb allocation size question
Date: Wed, 1 Sep 2010 11:51:02 -0700
Message-ID: <201009011151.02639.awilliams@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.19.149.2]:34139 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664Ab0IASv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 14:51:59 -0400
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 11:51:54 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been trying to track down an issue in one of our drivers with SKB 
allocation and in my research I came across something that seems a bit 
strange. In __alloc_skb, a block for the data allocates size + sizeof(struct 
skb_shared_info) bytes, yet skb->truesize is set to size + sizeof(struct 
sk_buff). Is there a reason for this discrepancy?

-Aaron Williams
