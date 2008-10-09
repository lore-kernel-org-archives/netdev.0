From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/6] bnx2: Eliminate TSO header modifications.
Date: Thu, 09 Oct 2008 12:25:58 -0700 (PDT)
Message-ID: <20081009.122558.246831931.davem@davemloft.net>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
	<1223572568-1298-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753867AbYJIT0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:26:22 -0400
In-Reply-To: <1223572568-1298-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu,  9 Oct 2008 10:16:06 -0700

> This is now possible with updated firmware.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Nice, applied.

Quick question, in the intermediate step where we have the
new firmware (patch #3) but not this change applied (patch
#4) does TSO still work properly?

If TSO is bolixed after patch #3 but before patch #4 please
don't create those kinds of non-bisectable situations in
the future.  I'd rather you do the firmware update and the
TSO logic changes all in one go to keep it all working.

Thanks!
