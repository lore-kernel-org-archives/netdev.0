From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH V7 net-next 5/7] xen-netfront: Factor queue-specific
 data into queue struct.
Date: Wed, 30 Apr 2014 15:59:18 +0100
Message-ID: <53610FC6.8000409@citrix.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>	<1398778035-26233-6-git-send-email-andrew.bennieston@citrix.com> <20140430145119.GE19082@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<paul.durrant@citrix.com>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>, <xen-devel@lists.xenproject.org>,
	<davem@davemloft.net>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53615 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759086AbaD3O7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 10:59:33 -0400
In-Reply-To: <20140430145119.GE19082@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/14 15:51, Wei Liu wrote:
> On Tue, Apr 29, 2014 at 02:27:13PM +0100, Andrew J. Bennieston wrote:
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
>> Reviewed-by: David Vrabel <david.vrabel@citrix.com>
> 
> Not an official netfront maintainer but FWIW this looks correct to me.

FYI, the frontend (including netfront) driver maintainers are the
general Xen maintainers; so myself, Boris and Konrad.

David
