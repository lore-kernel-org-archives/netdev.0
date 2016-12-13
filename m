From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v2] net: qcom/emac: don't try to claim clocks on ACPI
 systems
Date: Tue, 13 Dec 2016 15:54:53 -0800
Message-ID: <55991621-4068-a26f-6daa-ffc32b4b38db@gmail.com>
References: <1481672942-20024-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Christopher Covington <cov@codeaurora.org>,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35939 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbcLMXy4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 18:54:56 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so298239pgx.3
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 15:54:56 -0800 (PST)
In-Reply-To: <1481672942-20024-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2016 03:49 PM, Timur Tabi wrote:
> On ACPI systems, clocks are not available to drivers directly.  They are
> handled exclusively by ACPI and/or firmware, so there is no clock driver.
> Calls to clk_get() always fail, so we should not even attempt to claim
> any clocks on ACPI systems.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
