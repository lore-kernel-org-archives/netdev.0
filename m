From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] xen-netfront: frags -> slots in
 xennet_get_responses
Date: Mon, 25 Mar 2013 12:20:28 -0400 (EDT)
Message-ID: <20130325.122028.941252709121636615.davem@davemloft.net>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174Ab3CYQUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:20:30 -0400
In-Reply-To: <1364209702-12437-4-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 25 Mar 2013 11:08:19 +0000

> This function is in fact counting the ring slots required for responses.
> Separate the concepts of ring slots and skb frags make the code clearer, as
> now netfront and netback can have different MAX_SKB_FRAGS, slot and frag are
> not mapped 1:1 any more.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied.
