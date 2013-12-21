From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/3] bonding: add option lp_interval for loading
 module
Date: Sat, 21 Dec 2013 14:00:57 +0800
Message-ID: <52B52E99.7070809@huawei.com>
References: <52B3D15F.3080703@huawei.com> <52B44953.30703@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:58085 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab3LUGBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 01:01:33 -0500
In-Reply-To: <52B44953.30703@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/20 21:42, Sergei Shtylyov wrote:
> Hello.
> 
> On 20-12-2013 9:10, Ding Tianhong wrote:
> 
>> The bond driver could set the lp_interval when loading module.
> 
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/net/bonding/bond_main.c | 15 +++++++++++++--
>>   1 file changed, 13 insertions(+), 2 deletions(-)
> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index c0456cc..368f7e4 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
> [...]
>> @@ -4271,6 +4276,12 @@ static int bond_check_params(struct bond_params *params)
>>           fail_over_mac_value = BOND_FOM_NONE;
>>       }
>>
>> +    if (lp_interval == 0) {
>> +        pr_warning("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
>> +            INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
> 
>    The continuation line should be aligned under ", according to the networking coding style.
> 
> WBR, Sergei
> 
> 

Ok, I will fix it, thanks.

Regards
Ding

> 
