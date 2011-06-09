From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: emaclite: Add missing linux/interrupt.h header
Date: Thu, 09 Jun 2011 01:29:44 -0700 (PDT)
Message-ID: <20110609.012944.602872260942727070.davem@davemloft.net>
References: <1307607333-24612-1-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307607333-24612-1-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <monstr@monstr.eu>
Date: Thu,  9 Jun 2011 10:15:33 +0200

> Log:
> drivers/net/xilinx_emaclite.c: In function 'xemaclite_open':
> drivers/net/xilinx_emaclite.c:961: error: implicit declaration of function 'request_irq'
> drivers/net/xilinx_emaclite.c: In function 'xemaclite_close':
> drivers/net/xilinx_emaclite.c:995: error: implicit declaration of function 'free_irq'
> make[2]: *** [drivers/net/xilinx_emaclite.o] Error 1
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> 
> Signed-off-by: Michal Simek <monstr@monstr.eu>

This is only relevant for the -next tree, you should specify that when
submitting patches otherwise the maintainer not apply the patch where
it actually belongs.

Applied, thanks.
