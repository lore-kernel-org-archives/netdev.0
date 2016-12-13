From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: qcom/emac: don't try to claim clocks on ACPI systems
Date: Tue, 13 Dec 2016 15:54:08 -0600
Message-ID: <58506E00.9040801@codeaurora.org>
References: <1481658930-565-1-git-send-email-timur@codeaurora.org>
 <d6683e1c-803d-3859-f125-93fecaa0df02@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Christopher Covington <cov@codeaurora.org>,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53820 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932767AbcLMVyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 16:54:12 -0500
In-Reply-To: <d6683e1c-803d-3859-f125-93fecaa0df02@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2016 03:46 PM, Florian Fainelli wrote:
> Is there a reason why the check is not moved down inwo
> emac_clks_phase{1,2}_init functions? Do you anticipate other
> ACPI-related changes in the future that would warrant having this check
> moved at a higher level?

No, this is the last ACPI-related change that I expect.  I could move 
the check into those functions, but I don't see how that's any different 
than what I'm doing now.  My way avoids calling a function altogether, 
your way calls into a function only to have it return immediately.

But I don't have any strong feelings either way.  I will change it if 
you want me to.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
