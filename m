From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 01 Oct 2009 12:37:40 -0700 (PDT)
Message-ID: <20091001.123740.103898742.davem@davemloft.net>
References: <20091001111450.221969cc@s6510>
	<200910012139.32070.opurdila@ixiacom.com>
	<20091001115611.0baa77b8@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, cratiu@ixiacom.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755598AbZJAThU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 15:37:20 -0400
In-Reply-To: <20091001115611.0baa77b8@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 1 Oct 2009 11:56:11 -0700

> On Thu, 1 Oct 2009 21:39:32 +0300
> Octavian Purdila <opurdila@ixiacom.com> wrote:
> 
>> On Thursday 01 October 2009 21:14:50 you wrote:
>> > 
>> > Probably this should be a per interface property rather than per namespace.
>> 
>> In our case, where we have lots of interfaces active, it would be nice to have 
>> the per namespace property as well.
> 
> The ipv6 control infrastructure already has that option. If you changed your
> patch to use a per-interface control then there would be:
> 
>   /proc/sys/net/ipv6/conf/all/force_tllao

Right, this would work a lot better.
