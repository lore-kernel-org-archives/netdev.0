From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3.18] rtlwifi: Fix possible unaligned array in
 ether_addr_copy()
Date: Wed, 08 Oct 2014 15:00:19 -0400 (EDT)
Message-ID: <20141008.150019.1302200505918792300.davem@davemloft.net>
References: <1412790295-27858-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	troy_tan@realsil.com.cn, netdev@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbaJHTAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 15:00:23 -0400
In-Reply-To: <1412790295-27858-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Wed,  8 Oct 2014 12:44:55 -0500

> Two macros used to copy BSSID information use ether_addr_copy(), thus
> the arrays must be 2-byte aligned. In one case, the array could become
> unaligned if the struct containing it were changed. Use the __unaligned(2)
> attribute to retain the necessary alignment. In addition, the magic number
> used to specify the size of the array is replaced by ETH_ALEN.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Acked-by: David S. Miller <davem@davemloft.net>
