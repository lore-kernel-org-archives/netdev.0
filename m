From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 1/1] bring netlink interface to par with
 brctl show macs
Date: Thu, 29 May 2014 22:08:01 -0700 (PDT)
Message-ID: <20140529.220801.2111563710536999957.davem@davemloft.net>
References: <1401023755-8174-1-git-send-email-jhs@emojatatu.com>
	<1401071747.17377.111.camel@deadeye.wl.decadent.org.uk>
	<53831FDD.4020902@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	stephen@networkplumber.org, vyasevic@redhat.com,
	john.r.fastabend@intel.com, sfeldma@cumulusnetworks.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbaE3FIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 01:08:05 -0400
In-Reply-To: <53831FDD.4020902@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 26 May 2014 07:05:01 -0400

> On 05/25/14 22:35, Ben Hutchings wrote:
>> On Sun, 2014-05-25 at 09:15 -0400, Jamal Hadi Salim wrote:
> 
>>> +		if (dev == NULL) {
>>> + pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");
>>
>> You left another debug message here.
>>
>>> +			return -ENODEV;
>>>   		}
> 
>>> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s no dumper\n",
>>> +				dev->name);
>>
>> And here.
> 
> Those two just adhere to the coding style used in the rest of the fdb
> code. I could remove them and send subsequent patches to remove
> equivalent debugs in the rest of the code. To me they seem useful
> although i have seen very strong views against them in the past.

I think we have to get rid of these, because they are essentially
user triggerable.
