From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: marvell: Fix double free of hwmon device
Date: Thu, 09 Mar 2017 22:41:57 -0800 (PST)
Message-ID: <20170309.224157.1315315281299916659.davem@davemloft.net>
References: <1489089211-1052-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdCJGmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 01:42:16 -0500
In-Reply-To: <1489089211-1052-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu,  9 Mar 2017 20:53:31 +0100

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

Applied, thanks.
