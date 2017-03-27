From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 3/3] net: phy: allow EEE with SGMII interface modes
Date: Mon, 27 Mar 2017 09:47:31 -0700
Message-ID: <5d3c3ce0-fabc-6b96-c7e9-c2e46ffe4d23@gmail.com>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:32813 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751333AbdC0Qrj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 12:47:39 -0400
Received: by mail-qt0-f195.google.com with SMTP id r45so8414312qte.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 09:47:38 -0700 (PDT)
In-Reply-To: <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2017 02:59 AM, Russell King wrote:
> As EEE is able to work in SGMII mode as well, add it to the list of
> permissable EEE modes that phy_init_eee() will accept.  This is
> necessary so that EEE can work with an 88E1512 connected in SGMII mode.

As you mention in your cover letter, we should probably reverse this
test and make it reject modes where EEE has no chance of being supported
at all.

Other than that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
