From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2]: Fix link interrupt problem.
Date: Wed, 28 Mar 2007 14:17:49 -0700 (PDT)
Message-ID: <20070328.141749.93643817.davem@davemloft.net>
References: <1175119038.7911.11.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753055AbXC1VRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 17:17:50 -0400
In-Reply-To: <1175119038.7911.11.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 28 Mar 2007 13:57:18 -0800

> [BNX2]: Fix link interrupt problem.
> 
> bnx2_has_work()'s logic is flawed and can cause the driver to miss
> a link event.  The fix is to compare the status block's attn_bits
> and attn_bits_ack to determine if there is a link event.
> 
> Update version to 1.5.6.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
