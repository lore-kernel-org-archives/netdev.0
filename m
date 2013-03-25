From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] xen-netback: don't disconnect frontend when seeing
 oversize frame
Date: Mon, 25 Mar 2013 12:21:15 -0400 (EDT)
Message-ID: <20130325.122115.1660515665644521253.davem@davemloft.net>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272Ab3CYQVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:21:17 -0400
In-Reply-To: <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 25 Mar 2013 11:08:22 +0000

> Some buggy frontends may generate frames larger than 64 KiB. We should
> aggresively consume all slots and drop the packet instead of disconnecting the
> frontend.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Similarly, resubmit with the more descriptive commit message David
posted and also integrate any other feedback you've received.
