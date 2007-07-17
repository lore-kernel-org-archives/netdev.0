From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: remove unused argument to cong_avoid op
Date: Mon, 16 Jul 2007 18:36:04 -0700 (PDT)
Message-ID: <20070716.183604.78383718.davem@davemloft.net>
References: <20070716161951.65453706@oldman>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38446
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752300AbXGQBgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:36:01 -0400
In-Reply-To: <20070716161951.65453706@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 16 Jul 2007 16:19:51 +0100

> None of the existing TCP congestion controls use the rtt value pased
> in the ca_ops->cong_avoid interface.  Which is lucky because seq_rtt
> could have been -1 when handling a duplicate ack.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Looks good, applied, thanks Stephen.
