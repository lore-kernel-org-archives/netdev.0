From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE
 registers
Date: Wed, 23 Nov 2016 09:33:42 -0800
Message-ID: <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        mugunthanvnm@ti.com, roszenrami@gmail.com
To: yegorslists@googlemail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35162 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933539AbcKWRdp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:33:45 -0500
In-Reply-To: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2016 06:38 AM, yegorslists@googlemail.com wrote:
> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> Add the ability to query and set Energy Efficient Ethernet parameters
> via ethtool for applicable devices.

Are you sure this is enough to actually enable EEE? I don't see where
phy_init_eee() is called here, nor is the cpsw Ethernet controller part
configured to enable/disable EEE. EEE is not just a PHY thing, it
usually also needs to be configured properly at the Ethernet MAC/switch
level as well.

Just curious here.
-- 
Florian
