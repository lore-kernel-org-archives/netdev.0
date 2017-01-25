From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: phy: broadcom: use auxctl reading helper in
 BCM54612E code
Date: Wed, 25 Jan 2017 08:32:34 -0800
Message-ID: <04682ad9-1380-45e2-3fbe-d3419af78727@gmail.com>
References: <20170125155411.14922-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33404 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdAYQcg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:32:36 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so14660920pfg.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 08:32:36 -0800 (PST)
In-Reply-To: <20170125155411.14922-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 07:54 AM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> Starting with commit 5b4e29005123 ("net: phy: broadcom: add
> bcm54xx_auxctl_read") we have a reading helper so use it and avoid code
> duplication.
> It also means we don't need MII_BCM54XX_AUXCTL_SHDWSEL_MISC define as
> it's the same as MII_BCM54XX_AUXCTL_SHDWSEL_MISC just for reading needs
> (same value shifted by 12 bits).
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
