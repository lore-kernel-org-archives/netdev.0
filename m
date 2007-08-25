From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: optimize memcpy and memset
Date: Fri, 24 Aug 2007 22:35:56 -0700 (PDT)
Message-ID: <20070824.223556.40827066.davem@davemloft.net>
References: <20070817162950.6d8d07cd@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50031
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755646AbXHYFf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 01:35:57 -0400
In-Reply-To: <20070817162950.6d8d07cd@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 17 Aug 2007 16:29:50 -0700

> The ethernet header management only needs to handle a fixed
> size address (6 bytes). If the memcpy/memset are changed to
> be passed a constant length, then compiler can optimize for
> this case (and if it is smart eliminate string instructions).
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
