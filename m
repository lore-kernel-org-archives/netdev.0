From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bridge: eliminate call by reference
Date: Tue, 27 Mar 2007 19:17:47 -0700 (PDT)
Message-ID: <20070327.191747.30185499.davem@davemloft.net>
References: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933102AbXC1CRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 22:17:48 -0400
In-Reply-To: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 20 Mar 2007 14:12:51 -0700

> 
> Change the bridging hook to be simple function with return value
> rather than modifying the skb argument. This could generate better
> code and is cleaner.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.22
