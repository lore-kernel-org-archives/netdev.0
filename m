From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 1/3] net: bgmac: allocate struct bgmac just once &
 don't copy it
Date: Tue, 31 Jan 2017 10:07:07 -0800
Message-ID: <fa097960-f975-075a-be49-8460f38c0d0a@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
 <20170128210832.26174-2-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34586 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbdAaSHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:07:14 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so29048757pfb.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:07:14 -0800 (PST)
In-Reply-To: <20170128210832.26174-2-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2017 01:08 PM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> So far were were allocating struct bgmac in 3 places: platform code,
> bcma code and shared bgmac_enet_probe function. The reason for this was
> bgmac_enet_probe:
> 1) Requiring early-filled struct bgmac
> 2) Calling alloc_etherdev on its own in order to use netdev_priv later
> 
> This solution got few drawbacks:
> 1) Was duplicating allocating code
> 2) Required copying early-filled struct
> 3) Resulted in platform/bcma code having access only to unused struct
> 
> Solve this situation by simply extracting some probe code into the new
> bgmac_alloc function.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
