From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlabel: Fix build problems when IPv6 is not
 enabled
Date: Tue, 29 Nov 2011 16:49:41 -0500 (EST)
Message-ID: <20111129.164941.864264311882171503.davem@davemloft.net>
References: <20111129201054.20141.86401.stgit@sifl>
	<4ED555E4.4000006@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmoore@redhat.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1K2Vtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 16:49:53 -0500
In-Reply-To: <4ED555E4.4000006@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Tue, 29 Nov 2011 14:00:04 -0800

> On 11/29/2011 12:10 PM, Paul Moore wrote:
>> A recent fix to the the NetLabel code caused build problem with
>> configurations that did not have IPv6 enabled; see below:
>> 
>>  netlabel_kapi.c: In function 'netlbl_cfg_unlbl_map_add':
>>  netlabel_kapi.c:165:4:
>>   error: implicit declaration of function 'netlbl_af6list_add'
>> 
>> This patch fixes this problem by making the IPv6 specific code conditional
>> on the IPv6 configuration flags as we done in the rest of NetLabel and the
>> network stack as a whole.  We have to move some variable declarations
>> around as a result so things may not be quite as pretty, but at least it
>> builds cleanly now.
>> 
>> Some additional IPv6 conditionals were added to the NetLabel code as well
>> for the sake of consistency.
>> 
>> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
>> Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks everyone.
