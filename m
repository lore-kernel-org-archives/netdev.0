From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 04/11] net: mvmdio: remove duplicate locking
Date: Wed, 14 Jun 2017 10:01:03 -0700
Message-ID: <b7b5f716-9553-40fc-dc19-b016ed9cf2d9@gmail.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
 <20170614154911.14510-5-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk+kernel@armlinux.org.uk>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36443 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdFNRBI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:01:08 -0400
Received: by mail-qt0-f195.google.com with SMTP id s33so1122615qtg.3
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:01:07 -0700 (PDT)
In-Reply-To: <20170614154911.14510-5-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2017 08:49 AM, Antoine Tenart wrote:
> From: Russell King <rmk+kernel@armlinux.org.uk>
> 
> The MDIO layer already provides per-bus locking, so there's no need for
> MDIO bus drivers to do their own internal locking.  Remove this.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
