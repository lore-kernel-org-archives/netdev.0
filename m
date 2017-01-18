From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 18 Jan 2017 07:13:20 -0600
Message-ID: <5763c2fb-7286-15b0-091f-1abf26c0afe7@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
 <3291b7c1-7bf6-d776-adab-b89c9cd9be38@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55450 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752894AbdARNUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 08:20:39 -0500
In-Reply-To: <3291b7c1-7bf6-d776-adab-b89c9cd9be38@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi wrote:
> The fact that you see the warning means external autoneg completes before the
> SGMII side in best case or SGMII link remains down in worst case.

So I'm no expert on this.  Are you saying that I might possibly be doing 
things backwards in my driver?  That is, I should be configuring the 
SGMII side of the link before I start autonegotiation?

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
