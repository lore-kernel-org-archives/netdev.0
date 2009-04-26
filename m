From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Avoid extra wakeups of threads blocked in
 wait_for_packet()
Date: Sun, 26 Apr 2009 02:04:11 -0700 (PDT)
Message-ID: <20090426.020411.157511269.davem@davemloft.net>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>
	<49F3308B.1030507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux.com, jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751258AbZDZJET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2009 05:04:19 -0400
In-Reply-To: <49F3308B.1030507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 25 Apr 2009 17:47:23 +0200

> (All threads waiting on a socket are using same sk_sleep anchor)

Great stuff Eric.

We've discussed splitting the wait queue up before, but shorter-term
your idea is pretty cool too :-)
