From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 00/13] dsa: Broadcom Starfighter 2 switch support
Date: Wed, 27 Aug 2014 19:51:12 -0700
Message-ID: <CAGVrzcb_LuOLTkuVwBsssJM_qan3omTBPdJ7DN_W=in8EPZQLg@mail.gmail.com>
References: <1409184267-1696-1-git-send-email-f.fainelli@gmail.com>
 <20140827.181229.2168894985069137270.davem@davemloft.net> <20140827.183033.1723409609887880785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34995 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114AbaH1Cvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 22:51:53 -0400
Received: by mail-ie0-f169.google.com with SMTP id tr6so218989ieb.0
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 19:51:52 -0700 (PDT)
In-Reply-To: <20140827.183033.1723409609887880785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-27 18:30 GMT-07:00 David Miller <davem@davemloft.net>:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 27 Aug 2014 18:12:29 -0700 (PDT)
>
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Wed, 27 Aug 2014 17:04:14 -0700
>>
>>> This patch series adds support for the Broadcom Starfighter 2 (Roboswitch
>>> successor) using the existing DSA infrastructure. This integrated switch
>>> is heavily used in Set Top Box, Cable gateways and DSL gateways products
>>> from Broadcom, and to a larger extent the new ARM-based Wi-Fi routers although
>>> slightly differently.
>>
>> Series applied, thanks Florian.
>
> Florian, I had to make an adjustment to make your series work.
>
> The Tulip dmfe driver internally has static functions named phy_read()
> and phy_write().  I had to add a commit to rename them before your
> series.

Ah, I should have caught that.

>
> Please when adjusting globally visible interfaces, do an allmodconfig
> build to catch these kinds of problems.

Will do next time, thanks!

>
> Thanks.



-- 
Florian
