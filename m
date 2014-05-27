From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 1/2] net/mlx4_core: Deprecate use_prio module
 parameter
Date: Tue, 27 May 2014 11:08:38 +0300
Message-ID: <53844806.6030808@mellanox.com>
References: <1400488662-5657-1-git-send-email-amirv@mellanox.com>	 <1400488662-5657-2-git-send-email-amirv@mellanox.com> <1401132152.27743.2.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Carol Soto <clsoto@linux.vnet.ibm.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:44229 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752444AbaE0IIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 04:08:46 -0400
In-Reply-To: <1401132152.27743.2.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/2014 10:22 PM, Ben Hutchings wrote:
> On Mon, 2014-05-19 at 11:37 +0300, Amir Vadai wrote:
>> It was used for steering by user priority for A0 steering. A0 mode is
>> not supported anymore. Printing a message and ignoring the parameter.
>>
>> CC: Carol Soto <clsoto@linux.vnet.ibm.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/main.c | 8 ++++----
>>   include/linux/mlx4/device.h               | 1 -
>>   2 files changed, 4 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index a56f601..08ff5dd 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -132,8 +132,7 @@ MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VLANs per ETH port (0-7)");
>>
>>   static bool use_prio;
>>   module_param_named(use_prio, use_prio, bool, 0444);
>
> Perhaps the sysfs permissions should be set to 0 (i.e. not visible in
> sysfs)?
>
Good idea - since the series already applied, will send another patch.

[...]

>> +	if (use_prio != 0)
>> +		pr_warn("mlx4_core: use_prio - obsolete module param, ignored\n");
>
> You spell it pr_warning() in the adjacent logging statements.
Patch 2/2 "net/mlx4_core: Replace pr_warning() with pr_warn()" in this 
patch series will take care to the other pr_warning's

Thanks,
Amir

>
> Ben.
>
