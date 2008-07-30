From: David Miller <davem@davemloft.net>
Subject: Re: [patch 01/11] random32: seeding improvement
Date: Wed, 30 Jul 2008 16:29:32 -0700 (PDT)
Message-ID: <20080730.162932.105510394.davem@davemloft.net>
References: <200807301937.m6UJbXZk012423@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	ak@suse.de, bboissin@gmail.com, lloyd@randombit.net,
	mpm@selenic.com, shemminger@vyatta.com, tytso@mit.edu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51962
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752771AbYG3X3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:29:32 -0400
In-Reply-To: <200807301937.m6UJbXZk012423@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:33 -0700

> The rationale is:
>    * use u32 consistently
>    * no need to do LCG on values from (better) get_random_bytes
>    * use more data from get_random_bytes for secondary seeding
>    * don't reduce state space on srandom32()
>    * enforce state variable initialization restrictions
> 
> Note: the second paper has a version of random32() with even longer period
> and a version of random64() if needed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
