From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] net: qcom/emac: enable flow control if requested
Date: Tue, 1 Nov 2016 14:05:32 -0500
Message-ID: <5818E77C.7060604@codeaurora.org>
References: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
 <1478025055-13167-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47168 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbcKATFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 15:05:34 -0400
In-Reply-To: <1478025055-13167-2-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 01:30 PM, Timur Tabi wrote:
> +	if (!phydev->pause && phydev->asym_pause)
> +		mac |= TXFC;

I think this might be wrong, and nb8800_pause_config() has it right. 
This should be:

	if (!phydev->pause != !phydev->asym_pause)

which is a logical-xor.

Do you concur?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
