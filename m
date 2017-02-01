From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net-next 1/2] net: dsa: mv88e6xxx: Workaround missing
 PHY ID on mv88e6390
Date: Tue, 31 Jan 2017 18:45:11 -0800
Message-ID: <67d231c1-0c9b-138e-4fb0-1c83aad91cd0@gmail.com>
References: <1485916806-27299-1-git-send-email-andrew@lunn.ch>
 <1485916806-27299-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33242 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750978AbdBACwu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 21:52:50 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so30556535pfg.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 18:52:13 -0800 (PST)
In-Reply-To: <1485916806-27299-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2017 06:40 PM, Andrew Lunn wrote:
> The internal PHYs of the mv88e6390 do not have a model ID. Trap any
> calls to the ID register, and if it is zero, return the ID for the
> mv88e6390. The Marvell PHY driver can then bind to this ID.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
