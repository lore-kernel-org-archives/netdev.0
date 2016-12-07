From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 18/18] RDS: IB: add missing connection cache
 usage info
Date: Wed, 7 Dec 2016 08:44:04 -0800
Message-ID: <eac62d66-7a41-965d-8ecb-c2e4b651c39d@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
 <1481083316-11648-19-git-send-email-santosh.shilimkar@oracle.com>
 <20161207.105531.1347292514118544125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34938 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753366AbcLGQnt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 11:43:49 -0500
In-Reply-To: <20161207.105531.1347292514118544125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/7/2016 7:55 AM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Tue,  6 Dec 2016 20:01:56 -0800
>
>> rds-tools already support it.
>>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>> ---
>>  include/uapi/linux/rds.h | 1 +
>>  net/rds/ib.c             | 1 +
>>  2 files changed, 2 insertions(+)
>>
>> diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
>> index 3833113..410ae3c 100644
>> --- a/include/uapi/linux/rds.h
>> +++ b/include/uapi/linux/rds.h
>> @@ -183,6 +183,7 @@ struct rds_info_rdma_connection {
>>  	uint32_t	max_send_sge;
>>  	uint32_t	rdma_mr_max;
>>  	uint32_t	rdma_mr_size;
>> +	uint32_t	cache_allocs;
>>  };
>>
>>  /* RDS message Receive Path Latency points */
>
> What level of compatability exists here?  If we run an old tool on a new
> kernel, or a new tool on an old kernel, does it work properly?
>
Tools repo carries a copy of the header and thats how the old tool and
new tools have been running with older/newer kernels. There are few more
bits left before I can start using directly kernel header for newer
tools.

Moreover this particular parameter is only used for verbose mode which
isn't used in default options.

Regards,
Santosh
