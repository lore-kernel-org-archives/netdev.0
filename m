From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/27] HFI: Add HFI adapter control structure
Date: Sun, 17 Apr 2011 23:21:11 -0400
Message-ID: <4DABAE27.1020206@linux.vnet.ibm.com>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com> <1299100213-8770-2-git-send-email-dykmanj@linux.vnet.ibm.com> <20110302142126.193a8817@nehalam> <1299105870.4277.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57223 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab1DRDVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 23:21:18 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I3EPcY004200
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:14:25 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3I3LFb2093720
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:21:15 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3LFiB015991
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:21:15 -0600
In-Reply-To: <1299105870.4277.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2011 5:44 PM, Ben Hutchings wrote:
> On Wed, 2011-03-02 at 14:21 -0800, Stephen Hemminger wrote:
>> On Wed,  2 Mar 2011 16:09:48 -0500
>> dykmanj@linux.vnet.ibm.com wrote:
>>
>>> diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
>>> index 80790c6..6fe4e60 100644
>>> --- a/drivers/net/hfi/core/Makefile
>>> +++ b/drivers/net/hfi/core/Makefile
>>> @@ -1,5 +1,6 @@
>>>  #
>>>  # Makefile for the HFI device driver for IBM eServer System p
>>>  #
>>> -hfi_core-objs:=	hfidd_init.o
>>> +hfi_core-objs:=	hfidd_adpt.o \
>>> +		hfidd_init.o
>>>  obj-$(CONFIG_HFI) += hfi_core.o
>>> diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
>>> new file mode 100644
>>> index 0000000..d64fa38
>>> --- /dev/null
>>> +++ b/drivers/net/hfi/core/hfidd_adpt.c
> [...]
>>> +void hfidd_free_adapter(struct hfidd_acs *p_acs)
>>> +{
>>> +	kfree(p_acs);
>>> +	p_acs = NULL;
>>> +	return;
>>> +}
>>
>> If these were not in a separate file the could be marked as static.
> 
> I assume they're intending to add some more interesting code here in the
> next installment.
> 

Yes, there is more to come.

>> Doing a return; on last line of a void function is considered poor
>> style since it is unnecessary.
> 
> Assigning to a local variable just before returning is also silly.
> 
> Ben.
> 
Both removed in v2. 

Jim

