From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] xen-netfront: more multiqueue fixes
Date: Thu, 31 Jul 2014 22:24:17 -0700 (PDT)
Message-ID: <20140731.222417.1983575885717055551.davem@davemloft.net>
References: <1406824704-2275-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbaHAFYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:24:19 -0400
In-Reply-To: <1406824704-2275-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Thu, 31 Jul 2014 17:38:21 +0100

> A few more xen-netfront fixes for the multiqueue support added in
> 3.16-rc1.  It would be great if these could make it into 3.16 but I
> suspect it's a little late for that now.
> 
> The second patch fixes a significant resource leak that prevents
> guests from migrating more than a handful of times.
> 
> These have been tested by repeatedly migrating a guest over 250 times
> (it would previously fail with this guest after only 8 iterations).

Series applied to 'net', thanks.
