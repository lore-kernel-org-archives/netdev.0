From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH] net: sh_eth: fix build failure
Date: Fri, 30 Sep 2011 16:51:34 +0900
Message-ID: <4E857506.5030501@renesas.com>
References: <4E8534A9.3050002@renesas.com>
 <CABMQnVLRO1q=Oi7CWE=CJqYcUBD6s+z1JTWrO8W1wVmFwuA45w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <CABMQnVLRO1q=Oi7CWE=CJqYcUBD6s+z1JTWrO8W1wVmFwuA45w@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/09/30 15:55, Nobuhiro Iwamatsu wrote:
> 2011/9/30 Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>:
< snip >
>> +#include <linux/kernel.h>
>> +#include <linux/spinlock.h>
> These are not required.

The Documentation/SubmitChecklist says the following:

========================================================
1: If you use a facility then #include the file that defines/declares
   that facility.  Don't depend on other header files pulling in ones
   that you use.
========================================================

The sh_eth driver uses spinlock functions and some macros of kernel.h.
So, I think that I have to write their "#include" in the driver.

Best regards,
Yoshihiro Shimoda

> 
> Best regards,
>   Nobuhiro
> Nobuhiro Iwamatsu
> 
