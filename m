From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: Simplify dsa_slave_phy_setup()
Date: Thu, 26 Oct 2017 09:45:59 -0700
Message-ID: <34140cc6-d204-63fe-ae91-35286e277306@gmail.com>
References: <20171026003205.13673-1-f.fainelli@gmail.com>
 <db15ecb1-8d8d-88b0-d141-36bf7c0c91a8@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: =?UTF-8?Q?Martin_Hundeb=c3=b8ll?= <mnhu@prevas.dk>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:49986 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932127AbdJZQqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 12:46:03 -0400
Received: by mail-qk0-f194.google.com with SMTP id q83so5073409qke.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 09:46:03 -0700 (PDT)
In-Reply-To: <db15ecb1-8d8d-88b0-d141-36bf7c0c91a8@prevas.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2017 04:07 AM, Martin Hundebøll wrote:
> On 2017-10-26 02:32, Florian Fainelli wrote:
>> Remove the code that tried to identify if a PHY designated by Device
>> Tree required diversion through the DSA-created MDIO bus. This was
>> created mainly for the bcm_sf2.c driver back when it did not have its
>> own MDIO bus driver, which it now has since 461cd1b03e32 ("net: dsa:
>> bcm_sf2: Register our slave MDIO bus").
>>
>> Signed-off-by: Florian Fainelli<f.fainelli@gmail.com>
> 
> Tested-by: Martin Hundebøll <mnhu@prevas.dk>

Thanks Martin, does that correctly fix the problem you reported a week
ago on 639X?
-- 
Florian
