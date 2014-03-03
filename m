From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/4] ieee802154: add generic header
 handling routines
Date: Mon, 03 Mar 2014 16:38:32 -0500 (EST)
Message-ID: <20140303.163832.460322695570068404.davem@davemloft.net>
References: <1393860606-30803-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1393860606-30803-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbaCCVie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:38:34 -0500
In-Reply-To: <1393860606-30803-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Mon,  3 Mar 2014 16:30:03 +0100

> +/* pushes hdr onto the skb. fields of hdr->fc that can be calculated from
> + * the contents of hdr will be, and the actual value of those bits in
> +* hdr->fc will be ignored. this includes the INTRA_PAN bit and the frame

Please fix this comment's third line, there should be a leading space.

> +static void ieee802154_haddr_copy_swap(u8 *dest, const u8 *src)
> +{
> +	int i;
> +	for (i = 0; i < IEEE802154_ADDR_LEN; i++)
> +		dest[IEEE802154_ADDR_LEN - i - 1] = src[i];

Add an empty line between local variable declarations and code.
