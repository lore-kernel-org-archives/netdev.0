From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix bug in bnx2_free_rx_mem().
Date: Wed, 17 Dec 2008 19:06:20 -0800 (PST)
Message-ID: <20081217.190620.38650341.davem@davemloft.net>
References: <1229569149-18954-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750774AbYLRDGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:06:18 -0500
In-Reply-To: <1229569149-18954-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 17 Dec 2008 18:59:09 -0800

> DMA memory for the jumbo rx page rings was freed incorrectly using the
> wrong local variable as the array index.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-2.6, thanks Michael.
