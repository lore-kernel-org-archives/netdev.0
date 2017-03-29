From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: dsa2: Add basic support of devlink
Date: Tue, 28 Mar 2017 17:33:18 -0700
Message-ID: <2fe7ffc9-1bf1-537a-e361-33156a6f5a07@gmail.com>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
 <1490737507-7864-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, sfrench@samba.org,
        linux-cifs@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34217 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932759AbdC2AdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 20:33:24 -0400
In-Reply-To: <1490737507-7864-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2017 02:45 PM, Andrew Lunn wrote:
> Register the switch and its ports with devlink.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

root@net-vm:~# devlink -p port
mdio_bus/fixed-0:1f/0: type eth netdev lan1
mdio_bus/fixed-0:1f/1: type eth netdev lan2
mdio_bus/fixed-0:1f/2: type eth netdev lan3
mdio_bus/fixed-0:1f/3: type eth netdev lan4
mdio_bus/fixed-0:1f/5: type notset
root@net-vm:~# devlink -p dev
mdio_bus/fixed-0:1f
-- 
Florian
