From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 08/12] net: dsa: b53: Move EEE functions to b53
Date: Mon, 18 Sep 2017 15:33:52 -0700
Message-ID: <f76ae4bb-b2d4-7b2f-d465-527967f9f5e5@gmail.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
 <20170918214128.27896-9-f.fainelli@gmail.com>
 <87poan1w2q.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35066 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdIRWd5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:33:57 -0400
Received: by mail-wm0-f68.google.com with SMTP id e64so2223687wmi.2
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:33:57 -0700 (PDT)
In-Reply-To: <87poan1w2q.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2017 03:27 PM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> @@ -649,7 +595,7 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
>>  	core_writel(priv, reg, offset);
>>  
>>  	if (!phydev->is_pseudo_fixed_link)
>> -		p->eee_enabled = bcm_sf2_eee_init(ds, port, phydev);
>> +		p->eee_enabled = b53_eee_init(ds, port, phydev);
>>  }
> 
> I know this is a bit out-of-scope of this patch, but I have to say I am
> not confortable with having still phy device stuffs in switch drivers...

Yes, this is out of scope :)

> 
> Can this is_pseudo_fixed_link check + phy_eee_init + eee_enable be moved
> up to dsa_slave_adjust_link in a future patch maybe?

Not 100% positive this applies to all switches, which is why this is
still largely a switch driver decision.
-- 
Florian
