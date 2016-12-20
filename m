From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Which ethtool methods should I implement?
Date: Mon, 19 Dec 2016 17:40:41 -0800
Message-ID: <a7fbf45a-3b74-cbb8-f239-44c35717aabd@gmail.com>
References: <58588982.5030006@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35685 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754811AbcLTBkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 20:40:49 -0500
Received: by mail-pg0-f52.google.com with SMTP id i5so1392641pgh.2
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 17:40:48 -0800 (PST)
In-Reply-To: <58588982.5030006@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2016 05:29 PM, Timur Tabi wrote:
> I'm adding support for ethtool to my driver
> (drivers/net/ethernet/qualcomm/emac/), and I can't find any meaningful
> HOWTO documentation, so I'm not sure which methods I need to implement.
> 
> Is there some minimal set of must-have ethtool methods that should be
> implemented?  Since I support phylib, I guess I should use
> phy_ethtool_get_link_ksettings and phy_ethtool_set_link_ksettings.  What
> else?

Ideally, everything that is supported by your HW, but I would with the
basic essential stuff that you would need in case someone reports
problems with your driver like:

- statistics (MAC for sure) and PHY (if possible), -S
- ability to restart auto-negotation (-r)
- reporting of driver information (-i)
- support toggling and reporting NETIF_F_* features -k/-K
-- 
Florian
