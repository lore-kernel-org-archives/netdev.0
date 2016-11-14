From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Add support for ethtool::nway_reset
Date: Mon, 14 Nov 2016 16:33:05 -0500 (EST)
Message-ID: <20161114.163305.1253068652087279471.davem@davemloft.net>
References: <20161113212444.3777-1-f.fainelli@gmail.com>
        <680b3968-5cdc-2229-fb8d-e9e75f87809a@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753274AbcKNVdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:33:07 -0500
In-Reply-To: <680b3968-5cdc-2229-fb8d-e9e75f87809a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun, 13 Nov 2016 13:35:04 -0800

> Le 13/11/2016 à 13:24, Florian Fainelli a écrit :
>> If we have a PHY device, just invoke genphy_restart_aneg() to restart
>> auto-negotiation.
>> 
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> David, please drop this patch for now, since I have another one pending
> which is going to touch the net_device/phydev interaction, this one also
> causes a build warning since priv is not used.

Ok, thanks for letting me know.
