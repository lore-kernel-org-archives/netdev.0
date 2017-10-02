From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] RDS: IB: Limit the scope of has_fr/has_fmr variables
Date: Mon, 2 Oct 2017 13:30:43 -0700
Message-ID: <1172819f-1c28-7756-4874-aa89f50c0733@oracle.com>
References: <1506734030-15205-1-git-send-email-avinash.repaka@oracle.com>
 <20171001.225419.1632354964848604960.davem@davemloft.net>
 <20171001.225655.1261950191787562705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, avinash.repaka@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171001.225655.1261950191787562705.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/1/2017 10:56 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 01 Oct 2017 22:54:19 -0700 (PDT)
> 
>> From: Avinash Repaka <avinash.repaka@oracle.com>
>> Date: Fri, 29 Sep 2017 18:13:50 -0700
>>
>>> This patch fixes the scope of has_fr and has_fmr variables as they are
>>> needed only in rds_ib_add_one().
>>>
>>> Signed-off-by: Avinash Repaka <avinash.repaka@oracle.com>
>>
>> Applied.
> 
> Actually, reverted, this breaks the build.
> 
> net/rds/rdma_transport.c:38:10: fatal error: ib.h: No such file or directory
>   #include "ib.h"
> 
> Although I can't see how in the world this patch is causing such
> an error.
> 
Weird indeed. Will sort this out with Avinash. Thanks Dave.

Regards,
Santosh
