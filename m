From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bnx2: Use dev_kfree_skb() instead of the _irq
 version
Date: Thu, 29 Jun 2006 12:37:52 -0700 (PDT)
Message-ID: <20060629.123752.75430912.davem@davemloft.net>
References: <1151517555.3502.19.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932330AbWF2Thz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 15:37:55 -0400
To: mchan@broadcom.com
In-Reply-To: <1151517555.3502.19.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 28 Jun 2006 10:59:14 -0700

> Change all dev_kfree_skb_irq() and dev_kfree_skb_any() to
> dev_kfree_skb().  These calls are never used in irq context.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
