From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v3] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Tue, 6 Dec 2016 20:54:59 -0600
Message-ID: <58477A03.6000107@codeaurora.org>
References: <1481070443-15118-1-git-send-email-timur@codeaurora.org>
 <2c2aaf1d-05a5-d2bc-d04a-79224a4c6b43@gmail.com>
 <58476ACB.3030206@codeaurora.org>
 <f62595d4-2dd7-9cc3-7537-2ff186dadc8c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42302 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbcLGCz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 21:55:57 -0500
In-Reply-To: <f62595d4-2dd7-9cc3-7537-2ff186dadc8c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> which is why this made me think the & (SUPPORTED_Pause |
> SUPPPORTED_Asym_Pause) here is most likely redundant?

Well, like I said, better safe than sorry.  I'd rather keep the &= 
unless you have a strong objection.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
