From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Add IFF_NO_QUEUE flag
Date: Wed, 08 Jun 2016 21:00:14 -0700 (PDT)
Message-ID: <20160608.210014.1852381886881414893.davem@davemloft.net>
References: <1465412931-29567-1-git-send-email-dsa@cumulusnetworks.com>
	<2fb324b8-e107-3ed9-16e2-0cf59937081d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcFIEAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:00:21 -0400
In-Reply-To: <2fb324b8-e107-3ed9-16e2-0cf59937081d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 8 Jun 2016 19:31:51 -0600

> On 6/8/16 1:08 PM, David Ahern wrote:
>> Getting the following splat with ping in a VRF:
> 
> ...
> 
>> Fix by adding the IFF_NO_QUEUE flag for VRF devices.
>>
>> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a
>> seqcount")
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>  drivers/net/vrf.c | 2 ++
>>  1 file changed, 2 insertions(+)
> 
> Dave: drop this one. I'll resubmit a flags + features update after
> Eric resolves the lock issue.

Ok.
