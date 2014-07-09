From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: export phy_suspend and phy_resume
Date: Tue, 08 Jul 2014 21:06:13 -0700 (PDT)
Message-ID: <20140708.210613.1232730480526275679.davem@davemloft.net>
References: <1404841116-8274-1-git-send-email-f.fainelli@gmail.com>
	<20140708.203734.373515318594628840.davem@davemloft.net>
	<CAGVrzcYkswjw+kd3A3BJxXeyeUHvr4D+Ud7btNnJ=SRwP5AppA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbridgers2013@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbaGIEGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 00:06:14 -0400
In-Reply-To: <CAGVrzcYkswjw+kd3A3BJxXeyeUHvr4D+Ud7btNnJ=SRwP5AppA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 8 Jul 2014 20:59:47 -0700

> 2014-07-08 20:37 GMT-07:00 David Miller <davem@davemloft.net>:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Tue,  8 Jul 2014 10:38:36 -0700
>>
>>> phy_suspend and phy_resume are two commonly used helper functions that
>>> need to be exported for Ethernet drivers to be built as modules
>>>
>>> Fixes: 40755a0fce17 ("net: systemport: add suspend and resume support")
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> First of all, the commit in question went into 'net' not 'net-next'.
> 
> I am confused now, because I sent the patches against net-next and
> still see them in your net-next tree here:
> 
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=40755a0fce17c39557fd55b634024082671074ed
> 
>>
>> Second of all, I reverted it.
> 
> I remember you replied to Vince about his patches which also depended
> on phy_suspend/resume to be there and you did revert his changes.

Indeed, I confused your and Vince's patches.  Sorry about that.

I'll apply your patch to net-next, thanks.
