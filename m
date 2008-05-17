From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6 revised] [BNX2]: Remove the rx_offset
 field from the bnx2 structure.
Date: Fri, 16 May 2008 22:19:11 -0700 (PDT)
Message-ID: <20080516.221911.49059141.davem@davemloft.net>
References: <1210973417.5507.19.camel@dell>
	<20080516202942.GJ28241@solarflare.com>
	<1210976321.5938.16.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	andy@greyhouse.net, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751501AbYEQFTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 01:19:16 -0400
In-Reply-To: <1210976321.5938.16.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 16 May 2008 15:18:41 -0700

> [BNX2]: Remove the rx_offset field from the bnx2 structure.
> 
> The rx_offset field is set to a constant value and initialized
> only once.  By replacing all references to the rx_offset field,
> we can eliminate rx_offset from the bnx2 structure.  This will
> save 4 bytes for every bnx2 instance.
> 
> [Added parentheses to the definition of BNX2_RX_OFFSET, as noted
> by Ben Hutchings.]
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks for respinning this patch Michael.
