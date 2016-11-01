From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/2] net: qcom/emac: the emac driver requires pause frames
Date: Tue, 1 Nov 2016 13:40:17 -0500
Message-ID: <5818E191.4020601@codeaurora.org>
References: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40652 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbcKASkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:40:19 -0400
In-Reply-To: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qcom emac driver experiences significant packet loss (through frame 
check sequence errors) if flow control is not enabled and the phy is not 
configured to allow pause frames to pass through it.  Therefore, we need 
to force enable flow control and force the phy to pass pause frames.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
