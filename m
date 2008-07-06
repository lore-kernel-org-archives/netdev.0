From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 1/2] net_sched: add size table functions
Date: Sun, 06 Jul 2008 22:24:03 +0200
Message-ID: <487129E3.8010006@trash.net>
References: <20080703220311.30053.63477.stgit@fate.lan> <20080705.233105.145299915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39047 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796AbYGFUYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 16:24:07 -0400
In-Reply-To: <20080705.233105.145299915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Date: Fri, 04 Jul 2008 01:03:12 +0300
> 
>> Patch adds size table that is similiar to rate table, with difference that
>> size table stores link layer packet size. It's needed for HFSC link
>> layer adaption patch as it converts skb->len to link layer packet size
>> directly, unlike HTB/CFQ/etc that convert packet length to link layer
>> transfer time using rate tables.
>>
>> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> 
> Ok.
> 
> Patrick, can you give some feedback on these two patches?

Sure, I'll review them tommorrow. Want to finish some VLAN fixes first.
