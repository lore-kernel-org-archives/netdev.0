From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: emaclite: Add missing linux/interrupt.h header
Date: Thu, 09 Jun 2011 10:56:42 +0200
Message-ID: <4DF08ACA.30507@monstr.eu>
References: <1307607333-24612-1-git-send-email-monstr@monstr.eu> <20110609.012944.602872260942727070.davem@davemloft.net>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110609.012944.602872260942727070.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Michal Simek <monstr@monstr.eu>
> Date: Thu,  9 Jun 2011 10:15:33 +0200
> 
>> Log:
>> drivers/net/xilinx_emaclite.c: In function 'xemaclite_open':
>> drivers/net/xilinx_emaclite.c:961: error: implicit declaration of function 'request_irq'
>> drivers/net/xilinx_emaclite.c: In function 'xemaclite_close':
>> drivers/net/xilinx_emaclite.c:995: error: implicit declaration of function 'free_irq'
>> make[2]: *** [drivers/net/xilinx_emaclite.o] Error 1
>> make[1]: *** [drivers/net] Error 2
>> make: *** [drivers] Error 2
>>
>> Signed-off-by: Michal Simek <monstr@monstr.eu>
> 
> This is only relevant for the -next tree, you should specify that when
> submitting patches otherwise the maintainer not apply the patch where
> it actually belongs.

sorry for that. Yes, it is for -next tree.

Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
