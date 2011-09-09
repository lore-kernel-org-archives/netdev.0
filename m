From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Fri, 9 Sep 2011 07:37:58 -0700 (PDT)
Message-ID: <67e08fa0-c2e1-44f8-ab8b-45e4bfdc9264@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Davem <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>,
	Rds-Devel <rds-devel@oss.oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:52232 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758953Ab1IIOiJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 10:38:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/08/2011 01:04 PM, Jonathan Lallinger wrote:
> In the rds_iw_mr_pool struct the free_pinned field keeps track of memory pinned
> by free MRs. While this field is incremented properly upon allocation, it is never
> decremented upon unmapping. This would cause the rds_rdma module to crash the
> kernel upon unloading, by triggering the BUG_ON in the rds_iw_destroy_mr_pool
> function.
>
> This change keeps track of the MRs that become unpinned, so that free_pinned
> can be decremented appropriately.
>
> Signed-off-by: Jonathan Lallinger<jonathan@ogc.us>
> Signed-off-by: Steve Wise<swise@ogc.us>

Signed-off-by: Venkat Venkatsubra<venkat.x.venkatsubra@oracle.com>

Venkat
