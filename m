From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: marvell: Fix double free of hwmon device
Date: Thu, 9 Mar 2017 11:58:22 -0800
Message-ID: <9b76fb09-e8fa-40d7-1128-828311521531@gmail.com>
References: <1489089211-1052-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35581 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdCIT6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 14:58:49 -0500
Received: by mail-qk0-f194.google.com with SMTP id o135so22322294qke.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 11:58:27 -0800 (PST)
In-Reply-To: <1489089211-1052-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2017 11:53 AM, Andrew Lunn wrote:
> The hwmon temperature sensor devices is registered using a devm_hwmon
> API call.  The marvell_release() would then manually free the device,
> not using a devm_hmon API, resulting in the device being removed
> twice, leading to a crash in kernfs_find_ns() during the second
> removal.
> 
> Remove the manual removal, which makes marvell_release() empty, so
> remove it as well.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 0b04680fdae4 ("phy: marvell: Add support for temperature sensor")

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
