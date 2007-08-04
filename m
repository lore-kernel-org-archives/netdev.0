From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2]: Fix suspend/resume problem.
Date: Fri, 03 Aug 2007 20:57:35 -0700 (PDT)
Message-ID: <20070803.205735.25476017.davem@davemloft.net>
References: <1186180354.18322.79.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762625AbXHDD5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 23:57:35 -0400
In-Reply-To: <1186180354.18322.79.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 03 Aug 2007 15:32:34 -0700

> [BNX2]: Fix suspend/resume problem.
> 
> The device would not resume properly if it was shutdown before the system
> was suspended.  In such scenario where the netif_running state is 0,
> bnx2_suspend() would not save the PCI state and so the memory enable bit
> and bus master enable bit would be lost.
> 
> We fix this by always saving and restoring the PCI state in
> bnx2_suspend() and bnx2_resume() regardless of netif_running() state.
> 
> Update version to 1.6.4.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Also applied, thanks Michael.
