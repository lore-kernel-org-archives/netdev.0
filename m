From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH 1/1] xen/netback: only non-freed SKB is
 queued into tx_queue
Date: Fri, 29 Jun 2012 00:50:37 -0700 (PDT)
Message-ID: <20120629.005037.1477386520087362696.davem@davemloft.net>
References: <1340794018-17274-1-git-send-email-annie.li@oracle.com>
	<20120628.165550.1816352825092253548.davem@davemloft.net>
	<1340954589.5953.12.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: annie.li@oracle.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, konrad.wilk@oracle.com,
	kurt.hackel@oracle.com
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab2F2Hui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 03:50:38 -0400
In-Reply-To: <1340954589.5953.12.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Fri, 29 Jun 2012 08:23:09 +0100

> On Fri, 2012-06-29 at 00:55 +0100, David Miller wrote:
>> From: annie.li@oracle.com
>> Date: Wed, 27 Jun 2012 18:46:58 +0800
>> 
>> > From: Annie Li <Annie.li@oracle.com>
>> > 
>> > After SKB is queued into tx_queue, it will be freed if request_gop is NULL.
>> > However, no dequeue action is called in this situation, it is likely that
>> > tx_queue constains freed SKB. This patch should fix this issue, and it is
>> > based on 3.5.0-rc4+.
>> > 
>> > This issue is found through code inspection, no bug is seen with it currently.
>> > I run netperf test for several hours, and no network regression was found.
>> > 
>> > Signed-off-by: Annie Li <annie.li@oracle.com>
>> 
>> I lack the expertiece necessary to properly review this, so I really
>> need a Xen expert to look this over.
> 
> Sorry, I put it to one side waiting for the repost to netdev and then
> forgot about it...
> 
> Yes, this change looks good to me:
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Thanks, applied to net-next.
