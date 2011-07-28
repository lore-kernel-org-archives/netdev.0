From: David Miller <davem@davemloft.net>
Subject: Re: invalid requirement from ethtool?
Date: Thu, 28 Jul 2011 00:37:58 -0700 (PDT)
Message-ID: <20110728.003758.292509567308751079.davem@davemloft.net>
References: <20110726124222.GA4842@mtldesk30>
	<20110727.224309.779719590419361909.davem@davemloft.net>
	<20110728072326.GC6750@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498Ab1G1HiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 03:38:06 -0400
In-Reply-To: <20110728072326.GC6750@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Thu, 28 Jul 2011 10:23:26 +0300

> On Wed, Jul 27, 2011 at 10:43:09PM -0700, David Miller wrote:
>> From: Eli Cohen <eli@dev.mellanox.co.il>
>> Date: Tue, 26 Jul 2011 15:42:22 +0300
>> 
>> > I think both params zero should be allowed and mean coalescing is not
>> > operational, thus we can remove these comments from ethtool.h
>> 
>> The existing precendence has existed for more than 10 years.  You can't
>> just change it like this.
>> 
>> You'll need to find a new way to encode "disabled" coalescing.
> 
> I can't see the text explicitly specifies how to "disable" coalescing.
> If I ignore the specific comment that disallows both params 0, I could
> interpret the text such that when they're both zero, the feature is
> disabled.

The documentation does not determine what the rules are, the cpu
does not execute the documentation it executes the code, and that's
what determines the rules.
