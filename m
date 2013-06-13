From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] bonding: couple of bug fixes
Date: Thu, 13 Jun 2013 02:33:50 -0700 (PDT)
Message-ID: <20130613.023350.937912692461490125.davem@davemloft.net>
References: <1370988422-2035-1-git-send-email-nikolay@redhat.com>
	<2290.1370988844@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758491Ab3FMJdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:33:51 -0400
In-Reply-To: <2290.1370988844@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 11 Jun 2013 15:14:04 -0700

> nikolay@redhat.com wrote:
> 
>>From: Nikolay Aleksandrov <nikolay@redhat.com>
>>
>>Hello,
>>Patch 01 resets the master's mac if the first enslave fails and the slave's
>>mac was set to the master's prior.
>>Patch 02 fixes a type bug of igmp_retrans (which is the counter of igmp_resend
>>param and was silently not working if the value was >127) so it can go up to 255
>>(as per documentation). It also fixes two tricky race conditions which were
>>hidden because of the previous bug.
>>
>>V2: Updated patch 02 commit message as per Jay's comment
> 
> 	For both patches:
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Series applied, thanks.
