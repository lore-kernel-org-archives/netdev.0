From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] net: phy: bcm7xxx: Plug in support for
 reading PHY error counters
Date: Mon, 28 Nov 2016 19:20:30 -0800
Message-ID: <0ec8808f-76df-d441-b4f4-8c0fd9136a3b@gmail.com>
References: <20161129010457.17438-1-f.fainelli@gmail.com>
 <20161129010457.17438-3-f.fainelli@gmail.com>
 <20161129025018.GA28968@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36701 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcK2DUc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 22:20:32 -0500
Received: by mail-oi0-f67.google.com with SMTP id u15so16610790oie.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 19:20:32 -0800 (PST)
In-Reply-To: <20161129025018.GA28968@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/28/16 à 18:50, Andrew Lunn a écrit :
>> +struct bcm7xxx_phy_priv {
>> +	u64	*stats;
>> +};
> 
>> +static int bcm7xxx_28nm_probe(struct phy_device *phydev)
>> +{
>> +	struct bcm7xxx_phy_priv *priv;
>> +
>> +	priv = devm_kzalloc(&phydev->mdio.dev, sizeof(*priv), GFP_KERNEL);
>> +	if (!priv)
>> +		return -ENOMEM;
>> +
>> +	phydev->priv = priv;
>> +
>> +	priv->stats = devm_kzalloc(&phydev->mdio.dev,
>> +				   bcm_phy_get_sset_count(phydev), GFP_KERNEL);
> 
> Hi Florian
> 
> Should there be a * sizeof(u64) in there?

It should thanks for noticing!
-- 
Florian
