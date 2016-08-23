From: Xander Huff <xander.huff@ni.com>
Subject: Re: [PATCH] net: phy: micrel: remove suspend/resume
Date: Tue, 23 Aug 2016 17:06:40 -0500
Message-ID: <57BCC8F0.4000803@ni.com>
References: <20160823111344.25FF41A2459@localhost.localdomain> <2ee9441d-1b3b-de6d-691d-b615c04c69d0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        brad.mouring@ni.com, nathan.sullivan@ni.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:53567 "EHLO ni.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758202AbcHWWG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 18:06:59 -0400
In-Reply-To: <2ee9441d-1b3b-de6d-691d-b615c04c69d0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/2016 2:03 PM, Florian Fainelli wrote:
> +others,
>
> On 08/23/2016 04:13 AM, Christophe Leroy wrote:
>> In ERRATA DS80000700A dated 05 May 2016, Microship recommends to
>> not use software power down mode on KSZ8041 family.
>
> s/Microship/Microchip/
>
>> They say they have no plan to fix this ERRATA in future releases.
>
> The errata applies to specific revisions, is this revision present in
> the lower 4 bits of the MII_PHYSID2 register such that it could be used
> to key the disabling of the power down?
>
>>
>> http://ww1.microchip.com/downloads/en/DeviceDoc/80000700A.pdf
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>> ---
>>   drivers/net/phy/micrel.c | 4 ----
>>   1 file changed, 4 deletions(-)
>>
>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> index 053e879..f456c55 100644
>> --- a/drivers/net/phy/micrel.c
>> +++ b/drivers/net/phy/micrel.c
>> @@ -837,8 +837,6 @@ static struct phy_driver ksphy_driver[] = {
>>   	.get_sset_count = kszphy_get_sset_count,
>>   	.get_strings	= kszphy_get_strings,
>>   	.get_stats	= kszphy_get_stats,
>> -	.suspend	= genphy_suspend,
>> -	.resume		= genphy_resume,
>>   }, {
>>   	.phy_id		= PHY_ID_KSZ8041RNLI,
>>   	.phy_id_mask	= MICREL_PHY_ID_MASK,
>> @@ -856,8 +854,6 @@ static struct phy_driver ksphy_driver[] = {
>>   	.get_sset_count = kszphy_get_sset_count,
>>   	.get_strings	= kszphy_get_strings,
>>   	.get_stats	= kszphy_get_stats,
>> -	.suspend	= genphy_suspend,
>> -	.resume		= genphy_resume,
>>   }, {
>>   	.phy_id		= PHY_ID_KSZ8051,
>>   	.phy_id_mask	= MICREL_PHY_ID_MASK,
>>
>
>
It doesn't appear that KSZ9031 is affected by this errata; no mention of suspend:

http://ww1.microchip.com/downloads/en/DeviceDoc/KSZ9031MNX_Errata_Rev%20A_A2_032515.pdf

-- 
Xander Huff
Staff Software Engineer
National Instruments
