From: David Miller <davem@davemloft.net>
Subject: Re: [FIB]: removes a memset() call in tnode_new()
Date: Sun, 13 Jan 2008 00:43:41 -0800 (PST)
Message-ID: <20080113.004341.219477909.davem@davemloft.net>
References: <4789BF2B.3040103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751173AbYAMInm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 03:43:42 -0500
In-Reply-To: <4789BF2B.3040103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 13 Jan 2008 08:35:07 +0100

> tnode_alloc() already clears allocated memory, using kcalloc()
> or alloc_pages(GFP_KERNEL|__GFP_ZERO, ...)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
