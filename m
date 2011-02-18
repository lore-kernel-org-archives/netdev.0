From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Always use single transmit and
 single receive hardware queues per device
Date: Thu, 17 Feb 2011 16:13:46 -0800 (PST)
Message-ID: <20110217.161346.52178777.davem@davemloft.net>
References: <20110217235719.6978.78272.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42348
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756689Ab1BRANK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:13:10 -0500
In-Reply-To: <20110217235719.6978.78272.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Thu, 17 Feb 2011 15:57:19 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> We believe that our earlier patch for supporting multiple hardware receive queues per enic device requires more internal testing. At this point, we think that it's best to disable the use of multiple receive queues. The current patch provides an effective means for the same.
> 
> Also, we continue to disallow multiple hardware transmit queues per device. But change the way we enforce this in order to maintain consistency with the way receive queues are handled.
> 
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

Applied.
