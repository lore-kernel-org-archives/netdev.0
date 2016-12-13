From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: qcom/emac: don't try to claim clocks on ACPI systems
Date: Tue, 13 Dec 2016 16:05:55 -0600
Message-ID: <585070C3.6060604@codeaurora.org>
References: <1481658930-565-1-git-send-email-timur@codeaurora.org>
 <d6683e1c-803d-3859-f125-93fecaa0df02@gmail.com>
 <58506E00.9040801@codeaurora.org>
 <e4666d2c-1690-0513-b2e2-57733f04a69c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Christopher Covington <cov@codeaurora.org>,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57628 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932541AbcLMWF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 17:05:59 -0500
In-Reply-To: <e4666d2c-1690-0513-b2e2-57733f04a69c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2016 04:02 PM, Florian Fainelli wrote:
> No strong feelings either, it just seems easier and safer to move the
> check down in the function and make it return success rather than
> potentially affecting the error path within the caller of
> emac_clks_phase{1,2}_init here.

I suppose that makes sense.  I'll post a V2.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
