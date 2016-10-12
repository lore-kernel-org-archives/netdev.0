From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v10 1/1] net: phy: Cleanup the Edge-Rate feature
 in Microsemi PHYs.
Date: Wed, 12 Oct 2016 02:14:15 -0700
Message-ID: <3065ffe9-ab57-7339-bb28-831ddf4adb5f@gmail.com>
References: <1476108825-14613-1-git-send-email-allan.nielsen@microsemi.com>
 <1476108825-14613-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:34495 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932564AbcJLKQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 06:16:49 -0400
Received: by mail-qt0-f177.google.com with SMTP id q7so11485248qtq.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 03:16:49 -0700 (PDT)
In-Reply-To: <1476108825-14613-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/10/2016 07:13 AM, Allan W. Nielsen wrote:
> Edge-Rate cleanup include the following:
> - Updated device tree bindings documentation for edge-rate
> - The edge-rate is now specified as a "slowdown", meaning that it is now
>   being specified as positive values instead of negative (both
>   documentation and implementation wise).
> - Only explicitly documented values for "vsc8531,vddmac" and
>   "vsc8531,edge-slowdown" are accepted by the device driver.
> - Deleted include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.
> - Read/validate devicetree settings in probe instead of init
> 
> Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> Signed-off-by: Raju Lakkaraju <raju.lakkaraju@microsemi.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
