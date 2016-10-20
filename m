From: Jeroen Hofstee <jhofstee@victronenergy.com>
Subject: Re: [PATCH] davinci_emac: fix setting the mac from DT
Date: Thu, 20 Oct 2016 15:35:19 +0200
Message-ID: <4caaccd7-69c4-ed5d-2e2e-6cf431fceeb4@victronenergy.com>
References: <1476904973-13226-1-git-send-email-jhofstee@victronenergy.com>
 <20161020124149.v47amnfbisndai4q@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S . Miller" <davem@davemloft.net>,
        "Anant Gole" <anantgole@ti.com>,
        Chaithrika U S <chaithrika@ti.com>,
        <linux-omap@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0103.outbound.protection.outlook.com ([104.47.2.103]:56736
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752986AbcJTUJu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 16:09:50 -0400
In-Reply-To: <20161020124149.v47amnfbisndai4q@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


On 20-10-16 14:41, Tony Lindgren wrote:
> * Jeroen Hofstee <jhofstee@victronenergy.com> [161019 12:39]:
>> commit 9120bd6e9f77 ("net: davinci_emac: Get device dm816x MAC address
>> using the cpsw code") sets the mac address to the one stored in the chip
>> unconditionally, overwritten the one already set from the device tree.
>> This patch makes sure the mac from DT is preserved.
>>
>> On a am3517 this address is incorrectly read as all zeros, making it
>> impossible to set a valid mac address without this patch.
> OK, at least I don't have better ideas for fixing this:

more details about the am3517 specific issue can be found
here http://marc.info/?l=linux-omap&m=147678889732646&w=2

Regards,
Jeroen
