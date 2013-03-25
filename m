From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Mon, 25 Mar 2013 12:20:50 -0400 (EDT)
Message-ID: <20130325.122050.360834873934327047.davem@davemloft.net>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184Ab3CYQUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:20:54 -0400
In-Reply-To: <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 25 Mar 2013 11:08:21 +0000

> This patch tries to coalesce tx requests when constructing grant copy
> structures. It enables netback to deal with situation when frontend's
> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> 
> It defines max_skb_slots, which is a estimation of the maximum number of slots
> a guest can send, anything bigger than that is considered malicious. Now it is
> set to 20, which should be enough to accommodate Linux (16 to 19).
> 
> Also change variable name from "frags" to "slots" in netbk_count_requests.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Please resubmit after you've incorporated the feedback you've
received.
