From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vrf: Remove direct access to skb->data
Date: Thu, 25 Feb 2016 15:36:16 -0500 (EST)
Message-ID: <20160225.153616.177421383036856818.davem@davemloft.net>
References: <1456251026-21898-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbcBYUgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 15:36:19 -0500
In-Reply-To: <1456251026-21898-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 23 Feb 2016 10:10:26 -0800

> Nik pointed that the VRF driver should be using skb_header_pointer
> instead of accessing skb->data and bits beyond directly which can
> be garbage.
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> Dave: This should go into v4.4 stable as well.

Applied and queued up for -stable, thanks.
