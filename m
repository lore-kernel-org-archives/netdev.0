From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net v1 0/3] amd-xgbe: AMD XGBE driver fixes 2017-02-28
Date: Thu, 2 Mar 2017 15:32:29 -0600
Message-ID: <a0806c50-958f-704a-e549-8b654f3787b2@amd.com>
References: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
 <20170302.130242.1337867667174030884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0065.outbound.protection.outlook.com ([104.47.36.65]:11318
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751149AbdCBVsq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 16:48:46 -0500
In-Reply-To: <20170302.130242.1337867667174030884.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2017 3:02 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Tue, 28 Feb 2017 15:02:42 -0600
>
>> This patch series addresses some issues in the AMD XGBE driver.
>>
>> The following fixes are included in this driver update series:
>>
>> - Stop the PHY before disabling and releasing device interrupts so that
>>   MDIO requests issued by the device can be properly handled
>> - Set the MDIO communication mode on device startup, not just device
>>   probe
>> - Do not overwrite SFP settings when mod_absent is detected
>>
>> This patch series is based on net.
>
> Series applied, thanks.

Thanks David!

Could you queue these fixes up against 4.10 stable. Nothing early than
that is needed.

Thanks,
Tom

>
