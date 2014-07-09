From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: export phy_suspend and phy_resume
Date: Tue, 8 Jul 2014 20:59:47 -0700
Message-ID: <CAGVrzcYkswjw+kd3A3BJxXeyeUHvr4D+Ud7btNnJ=SRwP5AppA@mail.gmail.com>
References: <1404841116-8274-1-git-send-email-f.fainelli@gmail.com> <20140708.203734.373515318594628840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:32812 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbaGIEA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 00:00:28 -0400
Received: by mail-oa0-f41.google.com with SMTP id l6so7483294oag.14
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 21:00:27 -0700 (PDT)
In-Reply-To: <20140708.203734.373515318594628840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-08 20:37 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue,  8 Jul 2014 10:38:36 -0700
>
>> phy_suspend and phy_resume are two commonly used helper functions that
>> need to be exported for Ethernet drivers to be built as modules
>>
>> Fixes: 40755a0fce17 ("net: systemport: add suspend and resume support")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>
> First of all, the commit in question went into 'net' not 'net-next'.

I am confused now, because I sent the patches against net-next and
still see them in your net-next tree here:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=40755a0fce17c39557fd55b634024082671074ed

>
> Second of all, I reverted it.

I remember you replied to Vince about his patches which also depended
on phy_suspend/resume to be there and you did revert his changes.

>
> So this patch is not appropriate unless/until that commit gets
> re-added, and it's not targetted at the proper tree anyways.
-- 
Florian
