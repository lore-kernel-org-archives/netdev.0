From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: define/use EESR_RX_CHECK macro
Date: Wed, 19 Jun 2013 22:27:50 +0400
Message-ID: <51C1F826.6040805@cogentembedded.com>
References: <201306190207.46832.sergei.shtylyov@cogentembedded.com> <CANqRtoRNnNuG_r+MW3Yb79jVK_iKm1bRTSvMhw1j4qsWZtphpw@mail.gmail.com> <20130619.005005.2262835197239818334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:34751 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934963Ab3FSS1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:27:49 -0400
Received: by mail-la0-f50.google.com with SMTP id dy20so4861130lab.9
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:27:47 -0700 (PDT)
In-Reply-To: <20130619.005005.2262835197239818334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/19/2013 11:50 AM, David Miller wrote:

>> On Wed, Jun 19, 2013 at 7:07 AM, Sergei Shtylyov
>> <sergei.shtylyov@cogentembedded.com> wrote:
>>> sh_eth_interrupt() uses the same Rx interrupt mask twice to check the interrupt
>>> status register -- #define EESR_RX_CHECK  and use it instead.

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> Thanks for the patch, nice to see that this driver is moving forward.

    Magnus, BTW, are you content with the amount of cleanup that is 
currently queued in the Dave Miller's 'net-next.git' repo, or should I 
move further: e.g., move the SoC specific fields like 'register_type' 
from the platform data to the driver's internal data structure?

>> Can you please include information about which SoC / board this code
>> has been tested on? As you know, the actual hardware that this driver
>> is operating on is not very well documented, so at least having
>> information about the SoC together with the commit message or patch
>> may help in the future.

> Sergei, please make this suggested change and resubmit this series, thank you.

    Hm, I guess Magnus didn't really mean patch #1 which doesn't change 
anything in the driver's behavior but only the actual NAPI support. OK, 
it was tested on R8A7778 BOCK-W board and I'll add that to the changelog.

WBR, Sergei
