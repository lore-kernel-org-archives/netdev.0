From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 1/2] ipv6 mcast: use del_timer_sync instead of del_timer
 in ipv6_mc_down
Date: Thu, 5 Sep 2013 10:20:52 -0700
Message-ID: <CAO7SqHA7R8-r_G+-oZfg-zUTnkG2wNCWwY6bRar77dnZPS13ZQ@mail.gmail.com>
References: <1378363359-37716-1-git-send-email-noureddine@aristanetworks.com>
	<1378391415.3159.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:49569 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab3IERUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 13:20:53 -0400
Received: by mail-vc0-f172.google.com with SMTP id m17so1387531vca.31
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 10:20:53 -0700 (PDT)
In-Reply-To: <1378391415.3159.3.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 7:30 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
>> index 99cd65c..5c8d49d 100644
>> --- a/net/ipv6/mcast.c
>> +++ b/net/ipv6/mcast.c
>> @@ -2277,12 +2277,12 @@ void ipv6_mc_down(struct inet6_dev *idev)
>>
>>       read_lock_bh(&idev->lock);
>>       idev->mc_ifc_count = 0;
>> -     if (del_timer(&idev->mc_ifc_timer))
>> +     if (del_timer_sync(&idev->mc_ifc_timer))
>
> Are you sure this doesn't introduce a potential deadlock?  Have you
> tested this with lockdep enabled?
>
> Ben.

I will test with lockdep enabled and get back to you.

Thanks,

Salam
