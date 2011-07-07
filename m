From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] sctp: Enforce retransmission limit during shutdown
Date: Thu, 07 Jul 2011 14:09:04 -0700 (PDT)
Message-ID: <20110707.140904.252541509664898900.davem@davemloft.net>
References: <4E148C16.8090505@hp.com>
	<20110707102835.GA6277@canuck.infradead.org>
	<4E15B65A.3010209@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yjwei@cn.fujitsu.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab1GGVJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 17:09:19 -0400
In-Reply-To: <4E15B65A.3010209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 07 Jul 2011 09:36:26 -0400

> On 07/07/2011 06:28 AM, Thomas Graf wrote:
>> When initiating a graceful shutdown while having data chunks
>> on the retransmission queue with a peer which is in zero
>> window mode the shutdown is never completed because the
>> retransmission error count is reset periodically by the
>> following two rules:
 ...
>> Signed-off-by: Thomas Graf <tgraf@infradead.org>
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
