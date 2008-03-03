From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: fix icmpv6_cleanup/icmpv6_init section
 mismatch
Date: Mon, 03 Mar 2008 12:03:56 -0800 (PST)
Message-ID: <20080303.120356.248538925.davem@davemloft.net>
References: <20080303125217.GA6026@localhost.sw.ru>
	<20080303145451.GC6026@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754428AbYCCUEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 15:04:12 -0500
In-Reply-To: <20080303145451.GC6026@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Mon, 3 Mar 2008 17:54:51 +0300

> Doh! Ignore this one. Below is correct.
> --------
> 
> [PATCH] ipv6: fix inet6_init/icmpv6_cleanup sections mismatch
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied.

However, dealing with all of these interactions between real
__{init,exit} and __net_{init,exit} becomes tiresome.

We used to be able to mark icmpv6_cleanup as __exit now
with the netns stuff we can't, that's a step backwards and
it's happening a lot as the conversions take place.
