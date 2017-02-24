From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH 1/1] rds: fix memory leak error
Date: Fri, 24 Feb 2017 11:20:32 -0800
Message-ID: <90d46c53-eae4-6cd0-56bb-ae3dab94928a@oracle.com>
References: <1487928481-1022-1-git-send-email-yanjun.zhu@oracle.com>
 <79081f83-c9ed-5e45-ecbb-754fe1c9a96a@oracle.com>
 <20170224.141225.195962886132763698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yanjun.zhu@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36026 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdBXTVG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 14:21:06 -0500
In-Reply-To: <20170224.141225.195962886132763698.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/24/17 11:12 AM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Fri, 24 Feb 2017 08:49:19 -0800
>
>> On 2/24/2017 1:28 AM, Zhu Yanjun wrote:
>>> When the function register_netdevice_notifier fails, the memory
>>> allocated by kmem_cache_create should be freed by the function
>>> kmem_cache_destroy.
>>>
>>> Cc: Joe Jin <joe.jin@oracle.com>
>>> Cc: Junxiao Bi <junxiao.bi@oracle.com>
>>> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
>>> ---
>> Minor nit with subject.
>> s/rds/RDS: TCP:
>
> Please, I definitely prefer people use all lowercase letters for
> the susbsystem prefix in the subject line.
>
Note for the future. Thanks Dave !!

Regards,
Santosh
