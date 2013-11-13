From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 0/10] bonding: rebuild the lock use for bond
 monitor
Date: Wed, 13 Nov 2013 10:26:06 +0100
Message-ID: <20131113092606.GG19702@redhat.com>
References: <527C4768.3010909@huawei.com>
 <20131108.014550.886693705136672248.davem@davemloft.net>
 <1384298787.3802.59.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Miller <davem@davemloft.net>, dingtianhong@huawei.com,
	fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758185Ab3KMJ23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 04:28:29 -0500
Content-Disposition: inline
In-Reply-To: <1384298787.3802.59.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 12, 2013 at 11:26:27PM +0000, Ben Hutchings wrote:
>On Fri, 2013-11-08 at 01:45 -0500, David Miller wrote:
>> Such patches should not be submitted at this time, the merge window
>> has openned up and therefore the net-next tree is closed.
>>
>> Please wait for the merge window to close and the net-next tree
>> to open back up before submitting these changes.
>
>These look like bug fixes that should have been submitted for the net
>tree.

I am not really sure that it's suitable for net tree, cause these aren't
really bugfixes - but rather locking removal. It might fix/improve some
situations - but the changes touch really sensitive parts and I think they
should go through net-next, to brew a little.

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
