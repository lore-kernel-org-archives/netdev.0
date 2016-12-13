From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: qcom/emac: don't try to claim clocks on ACPI systems
Date: Tue, 13 Dec 2016 14:02:15 -0800
Message-ID: <e4666d2c-1690-0513-b2e2-57733f04a69c@gmail.com>
References: <1481658930-565-1-git-send-email-timur@codeaurora.org>
 <d6683e1c-803d-3859-f125-93fecaa0df02@gmail.com>
 <58506E00.9040801@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Christopher Covington <cov@codeaurora.org>,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34313 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753904AbcLMWCU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 17:02:20 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so61292pgc.1
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 14:02:20 -0800 (PST)
In-Reply-To: <58506E00.9040801@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2016 01:54 PM, Timur Tabi wrote:
> On 12/13/2016 03:46 PM, Florian Fainelli wrote:
>> Is there a reason why the check is not moved down inwo
>> emac_clks_phase{1,2}_init functions? Do you anticipate other
>> ACPI-related changes in the future that would warrant having this check
>> moved at a higher level?
> 
> No, this is the last ACPI-related change that I expect.  I could move
> the check into those functions, but I don't see how that's any different
> than what I'm doing now.  My way avoids calling a function altogether,
> your way calls into a function only to have it return immediately.
> 
> But I don't have any strong feelings either way.  I will change it if
> you want me to.

No strong feelings either, it just seems easier and safer to move the
check down in the function and make it return success rather than
potentially affecting the error path within the caller of
emac_clks_phase{1,2}_init here.
-- 
Florian
