From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix compiler warning in
 bnx2_disable_forced_2g5().
Date: Fri, 11 Jun 2010 18:38:08 -0700 (PDT)
Message-ID: <20100611.183808.58442382.davem@davemloft.net>
References: <1276017690-5442-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prarit@redhat.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751745Ab0FLBh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 21:37:57 -0400
In-Reply-To: <1276017690-5442-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 8 Jun 2010 10:21:30 -0700

> drivers/net/bnx2.c: In function 'bnx2_disable_forced_2g5':
> drivers/net/bnx2.c:1489: warning: 'bmcr' may be used uninitialized in this function
> 
> We fix it by checking return values from all bnx2_read_phy() and proceeding
> to do read-modify-write only if the read operation is successful.
> 
> The related bnx2_enable_forced_2g5() is also fixed the same way.
> 
> Reported-by: Prarit Bhargava <prarit@redhat.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-next-2.6, thanks.
