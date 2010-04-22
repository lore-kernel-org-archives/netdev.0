From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: fix outsegs stat for TSO segments
Date: Thu, 22 Apr 2010 16:00:12 -0700 (PDT)
Message-ID: <20100422.160012.129774995.davem@davemloft.net>
References: <alpine.DEB.1.00.1004220956080.28813@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753632Ab0DVXAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 19:00:08 -0400
In-Reply-To: <alpine.DEB.1.00.1004220956080.28813@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 22 Apr 2010 10:00:24 -0700 (PDT)

> Account for TSO segments of an skb in TCP_MIB_OUTSEGS counter.  Without
> doing this, the counter can be off by orders of magnitude from the
> actual number of segments sent.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied to net-next-2.6, thanks Tom.
