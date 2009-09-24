From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Get rid of "Trying to free already-free IRQ"
Date: Thu, 24 Sep 2009 15:26:19 -0700 (PDT)
Message-ID: <20090924.152619.260814858.davem@davemloft.net>
References: <20090924183152.GA30254@oksana.dev.rtsoft.ru>
	<200909242230.33881.rjw@sisk.pl>
	<20090924213039.GA15904@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, linux-pm@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38527
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbZIXW0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 18:26:01 -0400
In-Reply-To: <20090924213039.GA15904@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Fri, 25 Sep 2009 01:30:39 +0400

> On Thu, Sep 24, 2009 at 10:30:33PM +0200, Rafael J. Wysocki wrote:
>> On Thursday 24 September 2009, Anton Vorontsov wrote:
>> > Following trace pops up if we try to suspend with 3c59x ethernet NIC
>> > brought down:
>> 
>> Patch looks good, but IMO it'd be a little effort to convert the driver to
>> dev_pm_ops while you're at it (please see r8169 for a working example).
> 
> I'd like to avoid putting irrelevant stuff into bugfixes.

Agreed.
