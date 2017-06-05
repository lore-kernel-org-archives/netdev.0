From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/6] net: phy: avoid genphy_aneg_done() for PHYs without
 clause 22 support
Date: Mon, 5 Jun 2017 09:29:22 -0700
Message-ID: <edb4654d-6df5-384c-4d1c-a329d193577d@gmail.com>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq63-0005Wr-K2@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35204 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751942AbdFEQ3Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 12:29:25 -0400
Received: by mail-qt0-f194.google.com with SMTP id x58so9686984qtc.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 09:29:24 -0700 (PDT)
In-Reply-To: <E1dHq63-0005Wr-K2@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2017 04:22 AM, Russell King wrote:
> Avoid calling genphy_aneg_done() for PHYs that do not implement the
> Clause 22 register set.
> 
> Clause 45 PHYs may implement the Clause 22 register set along with the
> Clause 22 extension MMD.  Hence, we can't simply block access to the
> Clause 22 functions based on the PHY being a Clause 45 PHY.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
