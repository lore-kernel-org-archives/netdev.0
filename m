From: Florian Fainelli <florian.fainelli@broadcom.com>
Subject: Re: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for
 downshift/Wirespeed
Date: Tue, 22 Nov 2016 13:01:07 -0800
Message-ID: <5c131c30-637a-1c9e-ebd5-6ca7a7f84d66@broadcom.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
 <20161122194058.29820-5-f.fainelli@gmail.com>
 <20161122200228.GG14947@lunn.ch>
 <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
 <20161122205747.GH14947@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35577 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755369AbcKVVIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 16:08:10 -0500
Received: by mail-pg0-f44.google.com with SMTP id p66so11274549pga.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 13:08:10 -0800 (PST)
In-Reply-To: <20161122205747.GH14947@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2016 12:57 PM, Andrew Lunn wrote:
>>> Maybe we should think about this locking a bit. It is normal for the
>>> lock to be held when using ops in the phy driver structure. The
>>> exception is suspend/resume. Maybe we should also take the lock before
>>> calling the phydev->drv->get_tunable() and phydev->drv->set_tunable()?
>>
>> Yes, that certainly seems like a good approach to me, let me cook a
>> patch doing that.
> 
> Hi Florian
> 
> There are a couple of mutex locks/unlocks you will need to remove from
> mscc.c when you centralize this mutex.

Good point, thanks, let me review the mscc PHY driver and propose a more
proper fix.
-- 
Florian
