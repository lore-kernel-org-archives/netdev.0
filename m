From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: skb_store_bits const is backwards
Date: Fri, 20 Apr 2007 16:40:11 -0700 (PDT)
Message-ID: <20070420.164011.133444351.davem@davemloft.net>
References: <20070420161314.21e8fa24@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbXDTXkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:40:08 -0400
In-Reply-To: <20070420161314.21e8fa24@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 20 Apr 2007 16:13:14 -0700

> Getting warnings becuase skb_store_bits has skb as constant,
> but the function overwrites it. Looks like const was on the
> wrong side.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Also applied, thanks a lot!
