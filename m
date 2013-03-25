From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] xen-netfront: remove unused variable `extra'
Date: Mon, 25 Mar 2013 12:20:22 -0400 (EDT)
Message-ID: <20130325.122022.1759291429760898811.davem@davemloft.net>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174Ab3CYQUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:20:25 -0400
In-Reply-To: <1364209702-12437-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 25 Mar 2013 11:08:17 +0000

> This variable is supposed to hold reference to the last extra_info in the
> loop. However there is only type of extra info here and the loop to process
> extra info is missing, so this variable is never used and causes confusion.
> 
> Remove it at the moment. We can add it back when necessary.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied.
