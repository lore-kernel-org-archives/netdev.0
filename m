From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cpsw: fix usage of
 cpdma_check_free_tx_desc()
Date: Wed, 13 Mar 2013 04:51:50 -0400 (EDT)
Message-ID: <20130313.045150.2214781310963907722.davem@davemloft.net>
References: <1363105879-26921-1-git-send-email-zonque@gmail.com>
	<513F8660.2010602@ti.com>
	<20130312202027.GA935@blumentopf>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, zonque@gmail.com, netdev@vger.kernel.org,
	s.neumann@raumfeld.com, koen@dominion.thruhere.net
To: andreas.fenkart@streamunlimited.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429Ab3CMIvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 04:51:39 -0400
In-Reply-To: <20130312202027.GA935@blumentopf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
Date: Tue, 12 Mar 2013 21:20:27 +0100

> On Wed, Mar 13, 2013 at 01:17:44AM +0530, Mugunthan V N wrote:
>> On 3/12/2013 10:01 PM, Daniel Mack wrote:
>> >Commit fae50823d0 ("net: ethernet: davinci_cpdma: Add boundary for rx
>> >and tx descriptors") introduced a function to check the current
>> >allocation state of tx packets. The return value is taken into account
>> >to stop the netqork queue on the adapter in case there are no free
>> >slots.
>> >
>> >However, cpdma_check_free_tx_desc() returns 'true' if there is room in
>> >the bitmap, not 'false', so the usage of the function is wrong.
>> >
>> >Signed-off-by: Daniel Mack <zonque@gmail.com>
>> >Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> >Reported-by: Sven Neumann <s.neumann@raumfeld.com>
>> >Reported-by: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
...
>> Tested-by: Mugunthan V N <mugunthanvnm@ti.com>
>> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
 ...
> This restores throughput to the level of 3.7.0
> 
> Tested-by: Andreas Fenkart <andreas.fenkart@streamunlimited.com>

Applied.
