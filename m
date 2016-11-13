From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: stmmac: Add support for ethtool::nway_reset
Date: Sun, 13 Nov 2016 13:35:04 -0800
Message-ID: <680b3968-5cdc-2229-fb8d-e9e75f87809a@gmail.com>
References: <20161113212444.3777-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        open list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32768 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934987AbcKMVfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 16:35:07 -0500
In-Reply-To: <20161113212444.3777-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/11/2016 à 13:24, Florian Fainelli a écrit :
> If we have a PHY device, just invoke genphy_restart_aneg() to restart
> auto-negotiation.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

David, please drop this patch for now, since I have another one pending
which is going to touch the net_device/phydev interaction, this one also
causes a build warning since priv is not used.

Thank you!
-- 
Florian
