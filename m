From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/3] bonding: add option lp_interval for loading
 module
Date: Sat, 21 Dec 2013 14:28:30 +0800
Message-ID: <52B5350E.7060203@huawei.com>
References: <52B3D15F.3080703@huawei.com> <469C6575-826C-4FF7-8FAE-78166EEB177B@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:17154 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab3LUG30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 01:29:26 -0500
In-Reply-To: <469C6575-826C-4FF7-8FAE-78166EEB177B@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/21 10:06, Scott Feldman wrote:
> 
> On Dec 19, 2013, at 9:10 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>> @@ -4271,6 +4276,12 @@ static int bond_check_params(struct bond_params *params)
>> 		fail_over_mac_value = BOND_FOM_NONE;
>> 	}
>>
>> +	if (lp_interval == 0) {
>> +		pr_warning("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
>> +			INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
>> +		lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
>> +	}
>> +
> 
> [sorry, replied with wrong email]
> 
> What do you think about using the new bond_option_xxx_set() functions for module parameters also?  The above code, for example, is duplicated in bond_option_lp_interval_set().  This way, we have a unified solution, where option bounds checking, compatibility, warnings, etc happened in one place for all three modes of input: sysfs, netlink, and module params.
> 
> -scott
> 

Yes, I agree with you, and I will wait for you to finish the bond_option_xxx_set() and then make the bond_check_params() use them, I think the code will be more simplify.
Thanks

Regards
ding 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
