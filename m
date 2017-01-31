From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: broadcom: rehook BCM54612E specific init
Date: Tue, 31 Jan 2017 14:14:05 -0800
Message-ID: <dd85a0f9-1e32-b464-fe8b-b2980e652376@gmail.com>
References: <20170131215454.7932-1-zajec5@gmail.com>
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
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36368 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750868AbdAaWOI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 17:14:08 -0500
Received: by mail-pf0-f194.google.com with SMTP id 19so29933772pfo.3
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 14:14:07 -0800 (PST)
In-Reply-To: <20170131215454.7932-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2017 01:54 PM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> This extra BCM54612E code in PHY driver isn't really aneg specific. Even
> without it aneg works OK but the problem is no packets pass through PHY.
> 
> Moreover putting this code inside config_aneg callback didn't allow
> resuming PHY correctly. When driver called phy_stop and phy_start it was
> putting PHY machine into RESUMING state. After that machine was
> switching into AN and NOLINK without ever calling phy_start_aneg. This
> prevented this extra setup from being called and PHY didn't work.
> 
> This change has been verified to fix network on BCM47186B0 SoC device
> with BCM54612E.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
