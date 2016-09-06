From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smsc: remove build warning of duplicate
 definition
Date: Tue, 06 Sep 2016 13:44:42 -0700 (PDT)
Message-ID: <20160906.134442.1557713234808594719.davem@davemloft.net>
References: <1473010341-10359-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473010341-10359-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Sun,  4 Sep 2016 23:02:21 +0530

> The build of m32r was giving warning:
> 
> In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
> drivers/net/ethernet/smsc/smc91x.h:448:0: warning: "SMC_inb" redefined
>  #define SMC_inb(ioaddr, reg)  ({ BUG(); 0; })
>  
> drivers/net/ethernet/smsc/smc91x.h:106:0:
> 	note: this is the location of the previous definition
>  #define SMC_inb(a, r)  inb(((u32)a) + (r))
>  
> drivers/net/ethernet/smsc/smc91x.h:449:0: warning: "SMC_outb" redefined
>  #define SMC_outb(x, ioaddr, reg) BUG()
>  
> drivers/net/ethernet/smsc/smc91x.h:108:0:
> 	note: this is the location of the previous definition
>  #define SMC_outb(v, a, r) outb(v, ((u32)a) + (r))
> 
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

Applied.
