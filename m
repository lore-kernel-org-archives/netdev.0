From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 07/11] net: mvmdio: check the MII_ADDR_C45 bit is not
 set for smi operations
Date: Wed, 14 Jun 2017 10:02:32 -0700
Message-ID: <326e1b80-be39-3fcc-ec3d-9fdfe6fc213e@gmail.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
 <20170614154911.14510-8-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34973 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbdFNRCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:02:36 -0400
Received: by mail-qt0-f195.google.com with SMTP id x58so1131852qtc.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:02:36 -0700 (PDT)
In-Reply-To: <20170614154911.14510-8-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2017 08:49 AM, Antoine Tenart wrote:
> Add a check for the read and write smi operations, to ensure the
> MII_ADDR_C45 bit isn't set. This will be needed as soon as the xSMI
> support is added to the mvmdio driver.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
