From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy/vitesse: Configure RGMII skew on VSC8601, if
 needed
Date: Mon, 14 Nov 2016 13:25:56 -0800
Message-ID: <d567c69f-6b57-7083-9090-df01fb140e36@gmail.com>
References: <1478993533-1936-1-git-send-email-alex.g@adaptrum.com>
 <20161114.161818.1460191406108019273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: gokhan@adaptrum.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, alex.g@adaptrum.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33458 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753175AbcKNV0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:26:01 -0500
In-Reply-To: <20161114.161818.1460191406108019273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 01:18 PM, David Miller wrote:
> From: Alexandru Gagniuc <alex.g@adaptrum.com>
> Date: Sat, 12 Nov 2016 15:32:13 -0800
> 
>> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
>> +		ret = vsc8601_add_skew(phydev);
> 
> I think you should use phy_interface_is_rgmii() here.
> 

This would include all RGMII modes, here I think the intent is to check
for PHY_INTERFACE_MODE_RGMII_ID and PHY_INTERFACE_MODE_RGMII_TXID (or
RXID),  Alexandru, what direction does the skew settings apply to?
-- 
Florian
