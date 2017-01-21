From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/8] net: dsa: mv88e6xxx: Workaround missing PHY
 ID on mv88e6390
Date: Fri, 20 Jan 2017 16:03:46 -0800
Message-ID: <37e5ab51-a26c-04ee-48f9-812bb2dbd87f@gmail.com>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
 <1484955062-26718-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33687 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbdAUADs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:03:48 -0500
Received: by mail-pf0-f194.google.com with SMTP id e4so6231760pfg.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 16:03:48 -0800 (PST)
In-Reply-To: <1484955062-26718-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2017 03:30 PM, Andrew Lunn wrote:
> The internal PHYs of the mv88e6390 do not have a model ID. Trap any
> calls to the ID register, and if it is zero, return the ID for the
> mv88e6390. The Marvell PHY driver can then bind to this ID.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Nice and clean!
-- 
Florian
