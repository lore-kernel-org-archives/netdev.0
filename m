From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Remove unnecessary condition check in phy
Date: Mon, 7 Apr 2014 18:09:00 -0700
Message-ID: <CAGVrzcbeFpd+7xgxPNVUW-TEVEeP+wh+XvVkgwvnQBJk7OqHCw@mail.gmail.com>
References: <533FB108.6010508@gmail.com> <20140407.145819.1044253560836772927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kumaran.4353@gmail.com, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:58034 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202AbaDHBJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 21:09:41 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so246836pbb.0
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 18:09:40 -0700 (PDT)
In-Reply-To: <20140407.145819.1044253560836772927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-07 11:58 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Balakumaran Kannan <kumaran.4353@gmail.com>
> Date: Sat, 05 Apr 2014 13:00:16 +0530
>
>> This condition check makes no difference in the code flow since 3.10
>>
>> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
>
> The big questions is, was this intentional?

It was before a33e6112d9b0 ("phy: Elimination the forced speed
reduction algorithm") because the PHY having PHY_HAS_MAGICANEG set
would not go through the PHY speed reduction algorithm. Now, this is
useless as there is a subsequent break and no conditional code based
on PHY_HAS_MAGICANEG (which means that we should also kill its usage
at some point).

Feel free to add my reviewed-by tag after fixing the mangling David spotted.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
