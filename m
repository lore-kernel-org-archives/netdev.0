From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [patch] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Wed, 13 Jul 2016 14:40:26 +0300
Message-ID: <24af412f-7fa5-fa2e-c605-21ea5d45f5ff@mellanox.com>
References: <20160713100825.GD29468@mwanda>
 <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Leon Romanovsky <leonro@mellanox.com>, <netdev@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Matan Barak <matanb@mellanox.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10041.outbound.protection.outlook.com ([40.107.1.41]:3107
	"EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751098AbcGNSOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 14:14:07 -0400
In-Reply-To: <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/2016 2:19 PM, Matan Barak wrote:
> I'm not sure EINVAL is the right error here though.
> Maybe -ENOTSUPP is a bit more appropriate here. 

I agree, Dan, can you please change to be along Matan's suggestion?

Or.
