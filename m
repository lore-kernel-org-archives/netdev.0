From: Jojy Varghese <jojy.varghese@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 8 Sep 2016 17:35:08 -0700
Message-ID: <CAJD3hpVDo+WVVM0cvcD2z8LzXrsyBPvPC1E72ETN_yG2rNaeLw@mail.gmail.com>
References: <1473373012.18970.13.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAJD3hpUMdSt6UXEFjU9OnU4K7qiET50xo8AQ194+4vpX2CfOUA@mail.gmail.com>
 <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com> <20160908.170443.533565891486140434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34917 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIAfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:35:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id a6so466107wmc.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 17:35:10 -0700 (PDT)
In-Reply-To: <20160908.170443.533565891486140434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the feedback guys. I appreciate it.

I am working with 4.4.3 kernel.  I will try to reproduce the issue
with the kernel tree at
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git.

In the meantime, the only data I have now is :
-  "dst-ifdown"  does not look correct since it will never release
reference to loopback device.
-  One way to fix might be to assign the 'dst''s net device to the
init net device. I thought adding reference to init net device's
loopback might be safe.

Any suggestion on debugging further is much appreciated.

-Jojy


On Thu, Sep 8, 2016 at 5:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Jojy Varghese <jojy.varghese@gmail.com>
> Date: Thu, 8 Sep 2016 16:33:38 -0700
>
>> Sorry last patch was just the delta over my original patch. Here is
>> the complete patch:
>
> It looks like you are grasping at straws.
>
> Please slow down and take the time to debug this properly.
>
> All of the mechanisms exist to make these references go away
> properly, but you are seeing a leak for some reason.
>
> Therefore, please work with Eric to discover where the real bug is
> instead of posting knee-jerk reaction patches every 15 minutes.
>
> Thank you.



-- 
Jojy G Varghese
