From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: [PATCH] RDSRDMA: Fix to PAGE_MASK interpretation
Date: Fri, 9 Sep 2011 07:35:42 -0700 (PDT)
Message-ID: <ab7cd84c-ad8b-46a3-bdc5-05ce34363260@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Davem <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>,
	Rds-Devel <rds-devel@oss.oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:34602 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab1IIOfw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 10:35:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 08/29/2011 02:28 PM, Jonathan Lallinger wrote:
> The RDS_RDMA rds_iw_map_scatterlist function assumed PAGE_MASK was the bitwise
> compliment of what it actually is. This problem was introduced in commit
> 404bb72a56e553febe1055f98347a7a3e3145759 when the variable dma_mask was replaced
> by PAGE_MASK, however dma_mask represented the compliment of what PAGE_MASK
> represents.
>
> This fix corrects the logic by flipping the compliments on all uses of PAGE_MASK
> int rds_iw_map_scatterlist.
>
> Signed-off by: Jonathan Lallinger<jonathan@ogc.us>

Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

Venkat
