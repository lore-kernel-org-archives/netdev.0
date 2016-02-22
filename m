From: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [net-next][PATCH 11/13] RDS: IB: add Fastreg MR (FRMR) detection
 support
Date: Mon, 22 Feb 2016 07:38:38 -0800
Message-ID: <56CB2B7E.5000402@sandisk.com>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
 <1455967804-27644-12-git-send-email-santosh.shilimkar@oracle.com>
 <20160221.223656.2213596964617869651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160221.223656.2213596964617869651.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/21/16 19:36, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Date: Sat, 20 Feb 2016 03:30:02 -0800
>
>> @@ -54,6 +55,8 @@ module_param(rds_ib_mr_8k_pool_size, int, 0444);
>>   MODULE_PARM_DESC(rds_ib_mr_8k_pool_size, " Max number of 8K mr per HCA");
>>   module_param(rds_ib_retry_count, int, 0444);
>>   MODULE_PARM_DESC(rds_ib_retry_count, " Number of hw retries before reporting an error");
>> +module_param(prefer_frmr, bool, 0444);
>> +MODULE_PARM_DESC(prefer_frmr, "Preferred MR method if both FMR and FRMR supported");
>
> Sorry, you're going to have to create a real run time method to configure
> this parameter.
>
> I'm strongly against module parameters.
>
> Please don't go into details about why this might be difficult to do,
> I'm totally not interested.  Doing things properly is sometimes not
> easy, that's life.

Hello Santosh,

What is the purpose of the prefer_frmr kernel module parameter ? Is this 
a parameter that is useful to RDS users or is its only purpose to allow 
developers of the RDS module to test both the FMR and FRMR code paths on 
hardware that supports both MR methods ?

Bart.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
