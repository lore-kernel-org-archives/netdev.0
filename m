From: David Miller <davem@davemloft.net>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Wed, 25 Apr 2007 14:01:46 -0700 (PDT)
Message-ID: <20070425.140146.49243484.davem@davemloft.net>
References: <462F54F3.9050306@trash.net>
	<20070425124449.98bf091c.akpm@linux-foundation.org>
	<462FBF5F.20909@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42172
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754116AbXDYVBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 17:01:39 -0400
In-Reply-To: <462FBF5F.20909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 25 Apr 2007 22:51:43 +0200

> [NETLINK]: don't reinitialize callback mutex
> 
> Don't reinitialize the callback mutex the netlink_kernel_create caller
> handed in, it is supposed to already be initialized and could already
> be held by someone.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks a lot for tracking this down Patrick.
