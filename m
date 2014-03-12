From: Carol Soto <clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Patch 1/2] IB/mlx5: Implementation of PCI error handler
Date: Wed, 12 Mar 2014 17:00:37 -0500
Message-ID: <5320D905.4060509@linux.vnet.ibm.com>
References: <20140312034219.637916521@linux.vnet.ibm.com> <20140312034512.065218504@linux.vnet.ibm.com> <1394649252.23624.36.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394649252.23624.36.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 3/12/2014 1:34 PM, Ben Hutchings wrote:
> On Tue, 2014-03-11 at 22:42 -0500, clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
> [...]
>> Index: b/include/linux/mlx5/driver.h
>> ===================================================================
>> --- a/include/linux/mlx5/driver.h
>> +++ b/include/linux/mlx5/driver.h
>> @@ -51,10 +51,10 @@ enum {
>>   };
>>   
>>   enum {
>> -       /* one minute for the sake of bringup. Generally, commands must always
>> +       /* 10 msecs for the sake of bringup. Generally, commands must always
>>           * complete and we may need to increase this timeout value
>>           */
>> -       MLX5_CMD_TIMEOUT_MSEC   = 7200 * 1000,
>> +       MLX5_CMD_TIMEOUT_MSEC   = 10 * 1000,
> You seem to be changing the timeout from 2 hours (not one minute) to 10
> seconds (not milliseconds).
>
> Ben.
Yes you are right the comment should say 10 seconds instead of 10 msecs.

Carol
>
>>          MLX5_CMD_WQ_MAX_NAME    = 32,
>>   };
>>   
>>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
