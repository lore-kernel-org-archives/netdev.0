From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Remove unnecessary condition check in phy
Date: Mon, 07 Apr 2014 21:15:37 -0400 (EDT)
Message-ID: <20140407.211537.2275013635206463873.davem@davemloft.net>
References: <533FB108.6010508@gmail.com>
	<20140407.145819.1044253560836772927.davem@davemloft.net>
	<CAGVrzcbeFpd+7xgxPNVUW-TEVEeP+wh+XvVkgwvnQBJk7OqHCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumaran.4353@gmail.com, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690AbaDHBPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 21:15:39 -0400
In-Reply-To: <CAGVrzcbeFpd+7xgxPNVUW-TEVEeP+wh+XvVkgwvnQBJk7OqHCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 7 Apr 2014 18:09:00 -0700

> 2014-04-07 11:58 GMT-07:00 David Miller <davem@davemloft.net>:
>> From: Balakumaran Kannan <kumaran.4353@gmail.com>
>> Date: Sat, 05 Apr 2014 13:00:16 +0530
>>
>>> This condition check makes no difference in the code flow since 3.10
>>>
>>> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
>>
>> The big questions is, was this intentional?
> 
> It was before a33e6112d9b0 ("phy: Elimination the forced speed
> reduction algorithm") because the PHY having PHY_HAS_MAGICANEG set
> would not go through the PHY speed reduction algorithm. Now, this is
> useless as there is a subsequent break and no conditional code based
> on PHY_HAS_MAGICANEG (which means that we should also kill its usage
> at some point).

Yep, I read through the history and that's why I noticed the patch didn't
apply, I was about to apply it :-)

> Feel free to add my reviewed-by tag after fixing the mangling David spotted.
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Will do, thanks Florian.
