From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 2/3] net: phy: restart phy autonegotiation after
 EEE advertisment change
Date: Mon, 27 Mar 2017 11:03:44 -0700
Message-ID: <d8316d09-155b-3200-0f03-f559fb7c68e7@gmail.com>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQO-0004rE-Px@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew lunn <andrew@lunn.ch>
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34427 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdC0SDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:03:54 -0400
Received: by mail-wr0-f196.google.com with SMTP id w43so12685254wrb.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:03:53 -0700 (PDT)
In-Reply-To: <E1csRQO-0004rE-Px@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2017 02:58 AM, Russell King wrote:
> When the EEE advertisment is changed, we should restart autonegotiation
> to update the link partner with the new EEE settings.  Add this trigger
> but only if the advertisment has changed.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
