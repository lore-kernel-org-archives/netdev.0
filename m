From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: refactor sctp_outq_teardown to insure proper
 re-initalization
Date: Thu, 17 Jan 2013 18:40:38 -0500 (EST)
Message-ID: <20130117.184038.2028006072256759665.davem@davemloft.net>
References: <1358457308-6407-1-git-send-email-nhorman@tuxdriver.com>
	<50F87FB4.3070604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
	Jamie.Parsons@metaswitch.com, netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab3AQXkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 18:40:42 -0500
In-Reply-To: <50F87FB4.3070604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Thu, 17 Jan 2013 17:48:20 -0500

> On 01/17/2013 04:15 PM, Neil Horman wrote:
>> Jamie Parsons reported a problem recently, in which the
>> re-initalization of an
>> association (The duplicate init case), resulted in a loss of receive
>> window
>> space.  He tracked down the root cause to sctp_outq_teardown, which
>> discarded
>> all the data on an outq during a re-initalization of the corresponding
>> association, but never reset the outq->outstanding_data field to zero.
>> I wrote,
>> and he tested this fix, which does a proper full re-initalization of
>> the outq,
>> fixing this problem, and hopefully future proofing us from simmilar
>> issues down
>> the road.
>>
> 
> Good find.
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied and queued up for -stable, thanks everyone.
