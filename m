From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] phylib: update mdiobus_alloc() to allocate extra private
 space
Date: Fri, 16 Dec 2011 14:37:32 -0600
Message-ID: <4EEBAC0C.4020104@freescale.com>
References: <1323967895-5205-1-git-send-email-timur@freescale.com> <8ABCAC4C-1D11-41AD-AE46-96EB9D40588D@freescale.com> <4EEA2A61.8050302@freescale.com> <20111216.153254.1998330487051662169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <afleming@freescale.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:38544
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759766Ab1LPUhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:37:40 -0500
In-Reply-To: <20111216.153254.1998330487051662169.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Make the change how I suggested, where mdiobus_alloc() retains it's current
> function signature and semantics.  Then you can edit drivers as needed rather
> than from the beginning.

Yes, your approach makes much more sense.  I should have thought of it.

-- 
Timur Tabi
Linux kernel developer at Freescale
