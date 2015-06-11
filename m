From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: igb: fix the start time for periodic output
 signals
Date: Thu, 11 Jun 2015 16:04:21 -0700 (PDT)
Message-ID: <20150611.160421.1499600779826677161.davem@davemloft.net>
References: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
	<1434063545.3530.11.camel@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	jacob.e.keller@intel.com, matthew.vick@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbFKXEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 19:04:22 -0400
In-Reply-To: <1434063545.3530.11.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Jun 2015 15:59:05 -0700

> On Thu, 2015-06-11 at 14:51 +0200, Richard Cochran wrote:
>> When programming the start of a periodic output, the code wrongly
>> places
>> the seconds value into the "low" register and the nanoseconds into the
>> "high" register.  Even though this is backwards, it slipped through my
>> testing, because the re-arming code in the interrupt service routine
>> is
>> correct, and the signal does appear starting with the second edge.
>> 
>> This patch fixes the issue by programming the registers correctly.
>> 
>> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied and queued up for -stable, thanks.
