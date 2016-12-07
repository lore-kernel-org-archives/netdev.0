From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v3] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Tue, 6 Dec 2016 19:50:03 -0600
Message-ID: <58476ACB.3030206@codeaurora.org>
References: <1481070443-15118-1-git-send-email-timur@codeaurora.org>
 <2c2aaf1d-05a5-d2bc-d04a-79224a4c6b43@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59206 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751518AbcLGCOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 21:14:02 -0500
In-Reply-To: <2c2aaf1d-05a5-d2bc-d04a-79224a4c6b43@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
>> +	if (phydrv->features & (SUPPORTED_Pause | SUPPORTED_Asym_Pause)) {
>> >+		phydev->supported &= ~(SUPPORTED_Pause | SUPPORTED_Asym_Pause);
>> >+		phydev->supported |= phydrv->features &
>> >+				     (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
> Is not the & (SUPPORTED_Pause | SUPPORTED_Asym_Pause) redundant here anyway?

I'm just trying to be safe.  Can I be certain that those bits are 
already zero?

>
>> >+	} else {
>> >+		phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
> that part looks good.
>
>> >+	}
>> >+
>> >+	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
> but this one basically "undoes" what the if () clause did where we
> checked if either, or one of the two bits was already set?

Ugh, sorry.  I thought I deleted that before sending the patch out. 
I'll send out a v4 tomorrow.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
