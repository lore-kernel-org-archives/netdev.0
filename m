From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: phy: allow PHY drivers to implement
 their own software reset
Date: Mon, 17 Feb 2014 13:34:50 -0800
Message-ID: <CAGVrzcbejiyp1V=FMzLb6fTLyQkzmMLtyakLoikY_6yRhRjduA@mail.gmail.com>
References: <1392670366-31457-1-git-send-email-f.fainelli@gmail.com>
 <1392670366-31457-3-git-send-email-f.fainelli@gmail.com> <20140217.162343.325745613056866328.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:60521 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaBQVfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:35:30 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so15761880pab.7
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 13:35:30 -0800 (PST)
In-Reply-To: <20140217.162343.325745613056866328.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-17 13:23 GMT-08:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 17 Feb 2014 12:52:45 -0800
>
>> +     if (phydev->drv->soft_reset(phydev))
>> +             ret = phydev->drv->soft_reset(phydev);
>
> You're not testing if the method is NULL, you're actually invoking it.

That, and there was a typo in the Documentation patch, all fixed now, thanks!
-- 
Florian
