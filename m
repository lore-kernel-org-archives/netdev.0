From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net] amd-xgbe: Enable IRQs only if napi_complete_done() is
 true
Date: Fri, 10 Mar 2017 08:19:37 -0600
Message-ID: <ceb2935c-deac-1bcc-c833-ac2944487c98@amd.com>
References: <20170309234823.11010.87592.stgit@tlendack-t1.amdoffice.net>
 <20170309.183147.1115919481874028502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jeremy.linton@arm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0054.outbound.protection.outlook.com ([104.47.33.54]:54887
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S937919AbdCJOTx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Mar 2017 09:19:53 -0500
In-Reply-To: <20170309.183147.1115919481874028502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/9/2017 8:31 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Thu, 9 Mar 2017 17:48:23 -0600
>
>> Depending on the hardware, the amd-xgbe driver may use disable_irq_nosync()
>> and enable_irq() when an interrupt is received to process Rx packets. If
>> the napi_complete_done() return value isn't checked an unbalanced enable
>> for the IRQ could result, generating a warning stack trace.
>>
>> Update the driver to only enable interrupts if napi_complete_done() returns
>> true.
>>
>> Reported-by: Jeremy Linton <jeremy.linton@arm.com>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> Applied, thanks.

Thanks David!  The change to napi_complete_done() from void to bool
occurred in 4.10, can you queue this fix up against 4.10 stable?

Thanks,
Tom

>
