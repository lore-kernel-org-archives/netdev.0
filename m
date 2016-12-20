From: Timur Tabi <timur@codeaurora.org>
Subject: Which ethtool methods should I implement?
Date: Mon, 19 Dec 2016 19:29:38 -0600
Message-ID: <58588982.5030006@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49132 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbcLTB3k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 20:29:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm adding support for ethtool to my driver 
(drivers/net/ethernet/qualcomm/emac/), and I can't find any meaningful 
HOWTO documentation, so I'm not sure which methods I need to implement.

Is there some minimal set of must-have ethtool methods that should be 
implemented?  Since I support phylib, I guess I should use 
phy_ethtool_get_link_ksettings and phy_ethtool_set_link_ksettings.  What 
else?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
