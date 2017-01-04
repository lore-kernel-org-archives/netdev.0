From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: add extension of phy-mode for XLGMII
Date: Wed, 4 Jan 2017 10:46:50 -0800
Message-ID: <2b337a52-12d5-0c89-1c16-513a75bf7e70@gmail.com>
References: <b5378ab79043fe46027756546c17e0a54df4a9f0.1483505550.git.jiedeng@synopsys.com>
 <20170104.134207.1106369954702793597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jie.Deng1@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32793 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968955AbdADSs6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:48:58 -0500
In-Reply-To: <20170104.134207.1106369954702793597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 10:42 AM, David Miller wrote:
> From: Jie Deng <Jie.Deng1@synopsys.com>
> Date: Wed, 4 Jan 2017 13:04:04 +0800
> 
>> The Synopsys DWC_xlgmac core provides a multiplexed 40-Gigabit
>> Media-Independent Interface (XLGMII, an IEEE 802.3 Clause 81
>> compliant reconciliation sub-layer) for communication with
>> the 100/50/40/25-Gigabit PHY and 10-Gigabit Media-Independent
>> Interface (XGMII, an IEEE 802.3 Clause 46 compliant reconciliation
>> sub-layer) for communication with the 10-Gigabit PHY.
>>
>> Currently, There are only interface mode definitions for "xgmii".
>> This patch adds the definitions for the PHY layer to recognize
>> "xlgmii" as a valid PHY interface.
>>
>> Signed-off-by: Jie Deng <jiedeng@synopsys.com>
> 
> It makes no sense to add these definitions unless you also submit
> uses of them alongside at the same time.

Correct, also, this is incomplete, you must include a change to
Documentation/devicetree/bindings/net/ethernet.txt to reflect this new mode.

Thank you
-- 
Florian
