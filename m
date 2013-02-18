From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] xfrm: release neighbor upon dst destruction
Date: Mon, 18 Feb 2013 14:58:08 -0500 (EST)
Message-ID: <20130218.145808.1730142643182502981.davem@davemloft.net>
References: <311F962F-9DAF-4B24-B7FD-F158895D304D@ipflavors.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	yoshfuji@linux-ipv6.org
To: r.kuntz@ipflavors.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab3BRT6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 14:58:09 -0500
In-Reply-To: <311F962F-9DAF-4B24-B7FD-F158895D304D@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Romain KUNTZ <r.kuntz@ipflavors.com>
Date: Mon, 18 Feb 2013 13:36:24 +0100

> Neighbor is cloned in xfrm6_fill_dst but seems to never be released.
> Neighbor entry should be released when XFRM6 dst entry is destroyed
> in xfrm6_dst_destroy, otherwise references may be kept forever on 
> the device pointed by the neighbor entry.
> 
> I may not have understood all the subtleties of XFRM & dst so I would
> be happy to receive comments on this patch. 
> 
> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>

This patch is definitely correct.

Applied and queued up for -stable, thanks.
