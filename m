From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6][BNX2]: Refine remote PHY locking.
Date: Fri, 02 May 2008 16:58:31 -0700 (PDT)
Message-ID: <20080502.165831.109311044.davem@davemloft.net>
References: <1209595829.7941.60.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935579AbYEBX6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:58:32 -0400
In-Reply-To: <1209595829.7941.60.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 30 Apr 2008 15:50:29 -0700

> [BNX2]: Refine remote PHY locking.
> 
> bnx2_set_remote_link() should be called under bp->phy_lock to protect
> against concurrent polling and interrupt calls.  This change is needed
> by the next patch which will add one initial poll of the remote PHY
> link status.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
