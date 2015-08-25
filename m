From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [net-next:master 1267/1290] net/rds/ib_recv.c:382:28: sparse:
 incorrect type in initializer (different base types)
Date: Tue, 25 Aug 2015 16:03:57 -0700
Message-ID: <55DCF45D.6080501@oracle.com>
References: <201508260636.uzScUNFH%fengguang.wu@intel.com> <20150825.155500.290194488854444995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, ajaykumar.hotchandani@oracle.com,
	ssantosh@kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33294 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbbHYXD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:03:56 -0400
In-Reply-To: <20150825.155500.290194488854444995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/15 3:55 PM, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Wed, 26 Aug 2015 06:42:39 +0800
>
>> sparse warnings: (new ones prefixed by >>)
>>
>>>> net/rds/ib_recv.c:382:28: sparse: incorrect type in initializer (different base types)
>>     net/rds/ib_recv.c:382:28:    expected int [signed] can_wait
>>     net/rds/ib_recv.c:382:28:    got restricted gfp_t
>>     net/rds/ib_recv.c:828:23: sparse: cast to restricted __le64
>
> Fixed by:
>
> ====================
> [PATCH] rds: Fix improper gfp_t usage.
>
>>> net/rds/ib_recv.c:382:28: sparse: incorrect type in initializer (different base types)
>     net/rds/ib_recv.c:382:28:    expected int [signed] can_wait
>     net/rds/ib_recv.c:382:28:    got restricted gfp_t
>     net/rds/ib_recv.c:828:23: sparse: cast to restricted __le64
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
Thanks Dave. I was just creating the patch after noticing
the error from kbuild on my tree.

Regards,
Santosh
