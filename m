From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH ethtool v3 2/2] Ethtool: Implements
 ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY downshift
Date: Mon, 21 Nov 2016 17:51:31 -0800
Message-ID: <b8b7463f-0acc-fcfa-e3c0-251e8fdc24b8@gmail.com>
References: <1479384480-31201-1-git-send-email-allan.nielsen@microsemi.com>
 <1479384480-31201-3-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36022 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754185AbcKVBve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 20:51:34 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so402656pgx.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 17:51:34 -0800 (PST)
In-Reply-To: <1479384480-31201-3-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 04:08 AM, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Add ethtool get and set tunable to access PHY drivers.
> 
> Ethtool Help: ethtool -h for PHY tunables
>     ethtool --set-phy-tunable DEVNAME      Set PHY tunable
>                 [ downshift on|off [count N] ]
>     ethtool --get-phy-tunable DEVNAME      Get PHY tunable
>                 [ downshift ]
> 
> Ethtool ex:
>   ethtool --set-phy-tuanble eth0 downshift on
>   ethtool --set-phy-tuanble eth0 downshift off
>   ethtool --set-phy-tuanble eth0 downshift on count 2


s/tunable/tunable/

Since this will be used as examples for people testing this feature,
this is kind of important to get the example right ;)

Other than that:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

> 
>   ethtool --get-phy-tunable eth0 downshift
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> ---

> +.B downshift
> +For operation in cabling environments that are incompatible with 1000BASE-T,
> +PHY device provides an automatic link speed downshift operation.

Might be worth mentioning that this is particularly useful if you are
using a cable which does not have the 4 pairs for instance.
-- 
Florian
