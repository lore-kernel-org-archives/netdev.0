From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH 11/13] RDS: IB: add Fastreg MR (FRMR) detection
 support
Date: Mon, 22 Feb 2016 08:38:21 -0800
Message-ID: <56CB397D.1030603@oracle.com>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
 <1455967804-27644-12-git-send-email-santosh.shilimkar@oracle.com>
 <20160221.223656.2213596964617869651.davem@davemloft.net>
 <56CB2B7E.5000402@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bart Van Assche <bart.vanassche@sandisk.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56CB2B7E.5000402@sandisk.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/2016 7:38 AM, Bart Van Assche wrote:
> On 02/21/16 19:36, David Miller wrote:
>> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>> Date: Sat, 20 Feb 2016 03:30:02 -0800
>>
>>> @@ -54,6 +55,8 @@ module_param(rds_ib_mr_8k_pool_size, int, 0444);
>>>   MODULE_PARM_DESC(rds_ib_mr_8k_pool_size, " Max number of 8K mr per
>>> HCA");
>>>   module_param(rds_ib_retry_count, int, 0444);
>>>   MODULE_PARM_DESC(rds_ib_retry_count, " Number of hw retries before
>>> reporting an error");
>>> +module_param(prefer_frmr, bool, 0444);
>>> +MODULE_PARM_DESC(prefer_frmr, "Preferred MR method if both FMR and
>>> FRMR supported");
>>
>> Sorry, you're going to have to create a real run time method to configure
>> this parameter.
>>
>> I'm strongly against module parameters.
>>
>> Please don't go into details about why this might be difficult to do,
>> I'm totally not interested.  Doing things properly is sometimes not
>> easy, that's life.
>
Sure Dave. Will drop the parameter. The runtime detection is already
in place. When an HCA hardware supports both FMR and FRMR features,
parameter can be used as over-ride over a default selection.

> Hello Santosh,
>
> What is the purpose of the prefer_frmr kernel module parameter ? Is this
> a parameter that is useful to RDS users or is its only purpose to allow
> developers of the RDS module to test both the FMR and FRMR code paths on
> hardware that supports both MR methods ?
>
Right. Since FRMR in early phase still for RDS, it was useful on HCA's
which supports both registration methods. Its not a deal breaker so
am going to drop the parameter as mentioned above.

Regards,
Santosh
