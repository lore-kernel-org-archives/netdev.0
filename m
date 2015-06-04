From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 1/2] net/xen-netfront: Correct printf format
 in xennet_get_responses
Date: Thu, 4 Jun 2015 13:52:18 +0100
Message-ID: <55704A02.9010001@citrix.com>
References: <1433350510-12846-1-git-send-email-julien.grall@citrix.com>
	<1433350510-12846-2-git-send-email-julien.grall@citrix.com>
	<1433351196.4861.131.camel@perches.com> <5570484C.8040201@citrix.com>
 <557048B1.9070805@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>,
	Julien Grall <julien.grall@citrix.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49536 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbbFDMwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 08:52:54 -0400
In-Reply-To: <557048B1.9070805@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/15 13:46, David Vrabel wrote:
> On 04/06/15 13:45, Julien Grall wrote:
>> On 03/06/15 18:06, Joe Perches wrote:
>>> On Wed, 2015-06-03 at 17:55 +0100, Julien Grall wrote:
>>>> rx->status is an int16_t, print it using %d rather than %u in order to
>>>> have a meaningful value when the field is negative.
>>> []
>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>> []
>>>> @@ -733,7 +733,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
>>>>  		if (unlikely(rx->status < 0 ||
>>>>  			     rx->offset + rx->status > PAGE_SIZE)) {
>>>>  			if (net_ratelimit())
>>>> -				dev_warn(dev, "rx->offset: %x, size: %u\n",
>>>> +				dev_warn(dev, "rx->offset: %x, size: %d\n",
>>>
>>> If you're going to do this, perhaps it'd be sensible to
>>> also change the %x to %#x or 0x%x so that people don't
>>> mistake offset without an [a-f] for decimal.
>>
>> Good idea. I will resend a version of this series.
>>
>> David, can I keep you Reviewed-by for this change?#
> 
> Can you make the offset %d instead?

Sure.

> 
> You can keep the reviewed-by if you do this.

Thank you.



-- 
Julien Grall
