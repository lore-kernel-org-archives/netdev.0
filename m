From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Allocation of small packets on Rx
Date: Tue, 20 Dec 2011 10:30:26 +1100
Message-ID: <1324337426.30454.23.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54169 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126Ab1LSXa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 18:30:29 -0500
Received: from [IPv6:::1] (localhost.localdomain [127.0.0.1])
	by gate.crashing.org (8.14.1/8.13.8) with ESMTP id pBJNURUJ013658
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 17:30:28 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks !

For a driver that gets small packets "inline" in the rx descriptors, I
allocate the skb in the rx poll and copy the data to it.

Should I allocate an skb of the just the right size for the packet (+
eventual alignment) or is there any benefit to allocating all skb's the
same size ?

The max size of those "inline" packets is 256 bytes and the driver today
always allocate that. Does that "help" the allocator some way or should
I just allocate what is needed for each packet ?

Cheers,
Ben.
