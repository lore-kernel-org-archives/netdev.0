From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH v4 2/2] RDS: fix congestion map corruption for PAGE_SIZE >
 4k
Date: Fri, 8 Apr 2016 12:39:49 -0700
Message-ID: <57080905.4000506@oracle.com>
References: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
 <1460030256-16791-2-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29026 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053AbcDHTj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 15:39:56 -0400
In-Reply-To: <1460030256-16791-2-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/2016 4:57 AM, Shamir Rabinovitch wrote:
> When PAGE_SIZE > 4k single page can contain 2 RDS fragments. If
> 'rds_ib_cong_recv' ignore the RDS fragment offset in to the page it
> then read the data fragment as far congestion map update and lead to
> corruption of the RDS connection far congestion map.
>
> Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
