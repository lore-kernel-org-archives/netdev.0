From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dp83640: Fix tx timestamp overflow handling.
Date: Wed, 20 Jan 2016 18:54:43 -0800 (PST)
Message-ID: <20160120.185443.757622115704630474.davem@davemloft.net>
References: <1453285348-16022-1-git-send-email-manfred.rudigier@omicron.at>
	<20160120132545.GB2032@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred.rudigier@omicron.at, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759285AbcAUCyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:54:44 -0500
In-Reply-To: <20160120132545.GB2032@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 20 Jan 2016 14:25:45 +0100

> On Wed, Jan 20, 2016 at 11:22:28AM +0100, Manfred Rudigier wrote:
>> PHY status frames are not reliable, the PHY may not be able to send them
>> during heavy receive traffic. This overflow condition is signaled by the
>> PHY in the next status frame, but the driver did not make use of it.
>> Instead it always reported wrong tx timestamps to user space after an
>> overflow happened because it assigned newly received tx timestamps to old
>> packets in the queue.
>> 
>> This commit fixes this issue by clearing the tx timestamp queue every time
>> an overflow happens, so that no timestamps are delivered for overflow
>> packets. This way time stamping will continue correctly after an overflow.
> 
> Hi Manfred,
> 
> Thanks for finding and fixing this bug.
> 
> Dave, this patch should also go into stable.
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Applied and queued up for -stable, thanks everyone.
