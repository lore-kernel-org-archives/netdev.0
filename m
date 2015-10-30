From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next PATCH] RDS: convert bind hash table to re-sizable
 hashtable
Date: Fri, 30 Oct 2015 08:50:14 -0700
Message-ID: <563391B6.80006@oracle.com>
References: <1446072672-4325-1-git-send-email-santosh.shilimkar@oracle.com>
 <20151030.201536.285461609251750460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151030.201536.285461609251750460.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2015 4:15 AM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Wed, 28 Oct 2015 15:51:12 -0700
>
>> +					    &rs->rs_bound_node, ht_parms)) {
>>   			*port = rs->rs_bound_port;
>>   			ret = 0;
>>   			rdsdebug("rs %p binding to %pI4:%d\n",
>>   			  rs, &addr, (int)ntohs(*port));
>>   			break;
>>   		} else {
>> -			rds_sock_put(rrs);
>> +			rds_sock_put(rs);
>> +			ret = -ENOMEM;
>> +			break;
>>   		}
>> +
>>   	} while (rover++ != last);
>>
>>   	return ret;
>
> This final insert of an empty line is both inappropriate and even
> if it was it would not be related to this change.
>
Right. I just posted v2, dropping the empty line. Thanks !!

Regards,
Santosh
