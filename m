From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 2/3] net: bgmac: drop struct bcma_mdio we don't need
 anymore
Date: Tue, 31 Jan 2017 10:07:21 -0800
Message-ID: <9c4ed75b-8273-ca8e-7ff7-f4eb469f7895@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
 <20170128210832.26174-3-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36144 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752052AbdAaSH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:07:28 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so28989317pfo.3
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:07:23 -0800 (PST)
In-Reply-To: <20170128210832.26174-3-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2017 01:08 PM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> Adding struct bcma_mdio was a workaround for bcma code not having access
> to the struct bgmac used in the core code. Now we don't duplicate this
> struct we can just use it internally in bcma code.
> 
> This simplifies code & allows access to all bgmac driver details from
> all places in bcma code.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
