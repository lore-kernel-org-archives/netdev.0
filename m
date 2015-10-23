From: Joe Jin <joe.jin@oracle.com>
Subject: Re: [PATCH V2 2/2] xen-netfront: limit vnic max_queues number to
 online cpus
Date: Fri, 23 Oct 2015 17:39:32 +0800
Message-ID: <562A0054.1030200@oracle.com>
References: <5629FB31.5060806@oracle.com> <5629FB86.7010107@oracle.com>
 <562A1A6E02000078000ADEFB@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, wei.liu2@citrix.com,
	"David S. Miller" <davem@davemloft.net>,
	xen-devel@lists.xenproject.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46201 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbbJWJjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:39:46 -0400
In-Reply-To: <562A1A6E02000078000ADEFB@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2015 05:30 PM, Jan Beulich wrote:
>>>> On 23.10.15 at 11:19, <joe.jin@oracle.com> wrote:
>>  
>> @@ -164,6 +166,19 @@ struct netfront_rx_info {
>>  	struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
>>  };
>>  
>> +static int xennet_set_max_queues(const char *val, struct kernel_param *kp)
>> +{
>> +	unsigned int cpus = num_online_cpus();
>> +	unsigned int max_queues = simple_strtoul(val, NULL, 10);
>> +
>> +	if (max_queues == 0 || max_queues > cpus) {
>> +		pr_err("max_queues %u is out of range [0 - %u]!\n", 
> 
> I suppose you mean "...[1 - %u]!\n" here?

Yes you are right, you catch my fault again :)

Thanks so much, will resend new later.

Regards,
Joe

> Jan
> 


-- 
Oracle <http://www.oracle.com>
Joe Jin | Software Development Director | +8610.6106.5624
ORACLE | Linux and Virtualization
No. 24 Zhongguancun Software Park, Haidian District | 100193 Beijing 
