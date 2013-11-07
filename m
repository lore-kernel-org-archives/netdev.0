From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] tipc: message reassembly using
 fragment chain
Date: Thu, 07 Nov 2013 18:31:02 -0500 (EST)
Message-ID: <20131107.183102.1693364426762289735.davem@davemloft.net>
References: <1383726487-27929-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com, maloy@donjonn.com,
	paul.gortmaker@windriver.com, ying.xue@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab3KGXbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 18:31:09 -0500
In-Reply-To: <1383726487-27929-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 6 Nov 2013 09:28:04 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> We introduce a new reassembly algorithm that improves performance
> and eliminates the risk of causing out-of-memory situations.
> 
> v3: -Use skb_try_coalesce, and revert to fraglist if this does not succeed.
>     -Make sure reassembly list head is uncloned.
> 
> v2: -Rebased on Ying's indentation fix.
>     -Node unlock call in msg_fragmenter case moved from patch #2 to #1.
>      ('continue' with this lock held would cause spinlock recursion if only
>       patch #1 is used)

This looks great, applied, thanks Erik.
