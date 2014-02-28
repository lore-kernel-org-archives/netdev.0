From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V5 net-next 3/5] xen-netfront: Factor queue-specific data
 into queue struct.
Date: Fri, 28 Feb 2014 15:13:06 +0000
Message-ID: <5310A782.5050705@citrix.com>
References: <1393252387-17496-1-git-send-email-andrew.bennieston@citrix.com> <1393252387-17496-4-git-send-email-andrew.bennieston@citrix.com> <20140228150954.GM16241@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26738 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbaB1PNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 10:13:07 -0500
In-Reply-To: <20140228150954.GM16241@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/02/14 15:09, Wei Liu wrote:
> On Mon, Feb 24, 2014 at 02:33:05PM +0000, Andrew J. Bennieston wrote:
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>
>> In preparation for multi-queue support in xen-netfront, move the
>> queue-specific data from struct netfront_info to struct netfront_queue,
>> and update the rest of the code to use this.
>>
>> Also adds loops over queues where appropriate, even though only one is
>> configured at this point, and uses alloc_etherdev_mq() and the
>> corresponding multi-queue netif wake/start/stop functions in preparation
>> for multiple active queues.
>>
>> Finally, implements a trivial queue selection function suitable for
>> ndo_select_queue, which simply returns 0, selecting the first (and
>> only) queue.
>>
>> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
>
> Did you forget to add in David's "Reviewed-by"? Is there any significant
> change compared to the last submission?
>
> Wei.
>
No significant change. I just forgot.

Andrew
