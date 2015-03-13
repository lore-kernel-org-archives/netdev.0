From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] tipc: some optimizations and impovements
Date: Fri, 13 Mar 2015 15:44:59 -0400 (EDT)
Message-ID: <20150313.154459.801876044095572984.davem@davemloft.net>
References: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
	<20150313.125227.1523044445570081158.davem@davemloft.net>
	<550319E2.2020108@donjonn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: maloy@donjonn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504AbbCMTpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:45:04 -0400
In-Reply-To: <550319E2.2020108@donjonn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <maloy@donjonn.com>
Date: Fri, 13 Mar 2015 13:09:54 -0400

> On 15-03-13 12:52 PM, David Miller wrote:
>> From: Jon Maloy <jon.maloy@ericsson.com>
>> Date: Fri, 13 Mar 2015 10:27:33 -0400
>>
>> I also don't think you even need to clone the SKB there either.
> 
> I don't don't see how we can not. We may extract many
> buffers from different positions in the data area, which will
> be sent in different directions, and be freed at different
> moments of time.

Ok, sounds like you need to clone after all.
