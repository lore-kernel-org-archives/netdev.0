From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] ppp: fix segfaults introduced by netdev_priv changes
Date: Thu, 18 Dec 2008 10:28:19 +0000
Message-ID: <494A25C3.1050603@katalix.com>
References: <200812172202.mBHM2GHi012456@bert.katalix.com> <20081217.192047.117548302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangchen@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:57017 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164AbYLRKew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 05:34:52 -0500
In-Reply-To: <20081217.192047.117548302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Wed, 17 Dec 2008 22:02:16 GMT
> 
>> +	} else
>> +		ppp_unlock(ppp);
>> +
>>  	cardmap_set(&all_ppp_units, ppp->file.index, NULL);
>>  	ppp->file.dead = 1;
>>  	ppp->owner = NULL;
> 
> James, thanks for this fix.  But you'll need to respin this
> as it conflicts with the IDR changes that are in net-next-2.6
> (this cardmap_set call isn't there any more, for example).

The patch is against net-2.6. I assumed it was appropriate for net-2.6
since we're on rc8 and ppp has been broken since rc6. :) Sorry I didn't
mention that in the patch.

I'll spin a version for net-next-2.6 later today.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

