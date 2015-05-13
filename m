From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Tue, 12 May 2015 23:06:28 -0400 (EDT)
Message-ID: <20150512.230628.1787617651802981793.davem@davemloft.net>
References: <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
	<1431377466-6676-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, azhou@nicira.com,
	stephen@networkplumber.org, alexander.h.duyck@redhat.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934006AbbEMDGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:06:30 -0400
In-Reply-To: <1431377466-6676-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 11 May 2015 16:51:06 -0400

> This is an initial implementation of a netdev driver for GENEVE
> tunnels.  This implementation uses a fixed UDP port, and only supports
> point-to-point links with specific partner endpoints.  Only IPv4
> links are supported at this time.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> Changes in v2:
>  - removal of unneeded special lock for vni_list
>  - removal of geneve_net_vni_add/del (replaced by open code)
>  - break out of vni search loop in geneve_rx after match found
>  - no longer deferring socket open at ndo_init(), now doing it in ndo_open()
>  - check for non-multicast, non-zero remote link partner in newlink()
>  - remove now unused workqueue stuff

John, could you please repost the full series when you make changes
based upon feedback?  That helps me a lot.

Thanks!
