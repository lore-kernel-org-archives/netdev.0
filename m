From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Fix build module
Date: Tue, 31 Jan 2017 10:47:18 -0800
Message-ID: <6052524d-6990-0b7e-7460-2ea98a4db833@gmail.com>
References: <20170131031716.31304-1-f.fainelli@gmail.com>
 <20170131.003200.1606954363885799024.davem@davemloft.net>
 <8cdf8334-7b1e-641b-44b8-aec6a37d1b8c@gmail.com>
 <20170131.133725.1452309965989023156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36305 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdAaS4C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:56:02 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so29187398pfo.3
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:56:02 -0800 (PST)
In-Reply-To: <20170131.133725.1452309965989023156.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2017 10:37 AM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 31 Jan 2017 10:32:38 -0800
> 
>> On 01/30/2017 09:32 PM, David Miller wrote:
>>> From: Florian Fainelli <f.fainelli@gmail.com>
>>> Date: Mon, 30 Jan 2017 19:17:16 -0800
>>>
>>>> Commit 7318166cacad ("net: dsa: bcm_sf2: Add support for
>>>> ethtool::rxnfc") added a new object to build: bcm_sf2_cfp.o, but in
>>>> doing so, we essentially just built this object and no longer bcm_sf2.o.
>>>>
>>>> Fix this by creating a module named bcm-sf2.ko which links in bcm_sf2.o
>>>> and bcm_sf2_cfp.o.
>>>>
>>>> Fixes: 7318166cacad ("net: dsa: bcm_sf2: Add support for ethtool::rxnfc")
>>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>>
>>> Applied, thanks.
>>
>> I don't see it showing up on next-next yet, is it just queued locally?
>> Thanks!
> 
> The perils of working on different machines during the day :-)
> 
> It should be there now, sorry about that.
> 

No worries, thanks for the prompt fix!
-- 
Florian
