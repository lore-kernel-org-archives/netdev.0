From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
 sk_buff state
Date: Wed, 29 Apr 2009 14:53:38 -0700 (PDT)
Message-ID: <20090429.145338.149717676.davem@davemloft.net>
References: <20090429040501.GA32074@cuplxvomd02.corp.sa.net>
	<20090428.223058.119960146.davem@davemloft.net>
	<20090429151440.GA14266@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dvomlehn@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59686
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752399AbZD2Vxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 17:53:44 -0400
In-Reply-To: <20090429151440.GA14266@cuplxvomd02.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <dvomlehn@cisco.com>
Date: Wed, 29 Apr 2009 08:14:40 -0700

> On Tue, Apr 28, 2009 at 10:30:58PM -0700, David Miller wrote:
>> 
>> Sorry, for this to be useful distributions are going to turn it on by
>> default, and adding 24 bytes to struct sk_buff on 64-bit when we're
>> trying everything in our power to make it smaller rather than larger
>> is not acceptable.
> 
> That's like saying that any of the kernel debugging options have to be on
> by default.  I expect that most folks won't want this on unless they are
> looking for a bug. 

We don't have networking buffer structure elements that implement
debugging, and it's for a reason.

>> It's a useful change, something to keep in one's back pocket when
>> debugging something, but not for upstream, sorry.
> 
> Right. This is why it depends on KERNEL_DEBUG and why it is off by default.

All of this is moot if distributions decide to start turning this
on, and from my experience they will.
