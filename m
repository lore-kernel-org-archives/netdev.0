From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnx2: Fix reset bug on 5709
Date: Sun, 28 Nov 2010 10:49:34 -0800 (PST)
Message-ID: <20101128.104934.115939232.davem@davemloft.net>
References: <1290642535-20293-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36577
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866Ab0K1StI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 13:49:08 -0500
In-Reply-To: <1290642535-20293-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 24 Nov 2010 15:48:54 -0800

> From: Eddie Wai <waie@broadcom.com>
> 
> The 5709 chip requires the BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE bit to be
> cleared and polling for pending DMAs to complete before chip reset.
> Without this step, we've seen NMIs during repeated resets of the chip.
> 
> Signed-off-by: Eddie Wai <waie@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
