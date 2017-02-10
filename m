From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: cafe8df8b9bc clashes with DSA
Date: Fri, 10 Feb 2017 09:59:27 -0800
Message-ID: <97e083a4-b27d-ce3c-227e-4c328f4a8b88@gmail.com>
References: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com>
 <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com>
 <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: maowenan@huawei.com, netdev@vger.kernel.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36402 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750910AbdBJSBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:01:02 -0500
Received: by mail-qk0-f193.google.com with SMTP id i34so6064426qkh.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 09:59:30 -0800 (PST)
In-Reply-To: <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2017 09:55 AM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> Fixed in the "net" tree with:
>>
>> 6d9f66ac7fec2a6ccd649e5909806dfe36f1fc25 ("net: phy: Fix PHY module
>> checks and NULL deref in phy_attach_direct()"), applies fine to net-next
>> as well.
> 
> Correct, this fixes my setup. Shouldn't this be submitted to net-next as
> well then?

I indicated in the patch that this was also applicable to "net-next"
after David merged "net" into "net-next" [1]. We are getting close from
releasing 4.10 now, so I am assuming that David will close net-next
soon, and that usually means merging "net" back into "net-next", which
will get us the fix. David, is that correct?

[1]: http://patchwork.ozlabs.org/patch/725923/

> 
> Thanks,
> 
>         Vivien
> 


-- 
Florian
