From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH] net: sxgbe: Added tail point update
Date: Fri, 09 May 2014 09:48:27 +0900
Message-ID: <002a01cf6b20$6417ca80$2c475f80$%an@samsung.com>
References: <008b01cf69cc$4d304e50$e790eaf0$%an@samsung.com>
 <CAGVrzcaic-rrbRg2CpvzpyTpt0iRtX9=QE8WLpR3Eep=8w5czQ@mail.gmail.com>
 <002f01cf6a5b$a92e3660$fb8aa320$%an@samsung.com>
 <20140508084447.GA8079@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Florian Fainelli' <f.fainelli@gmail.com>,
	'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org,
	'David Miller' <davem@davemloft.net>,
	"'ks.giri'" <ks.giri@samsung.com>,
	"'vipul.pandya'" <vipul.pandya@samsung.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140508084447.GA8079@electric-eye.fr.zoreil.com>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote :
> Byungho An <bh74.an@samsung.com> :
> > Florian Fainelli wrote:
> [...]
> > > I think that at some point you should revisit your abstraction, all
> > > the patches that I see do take a void __iomem * argument as the first
> > > function argument, you should probably use your driver private context
> > > here. The day you support a different version of the hardware, there
> > > might be other differences that need to be taken care of.
> > >
> > I agree with you, it would be more robust for different version of the
> hardware and make simple function argument.
> > But most functions of this driver deal with read/write register using
> ioaddr.
> 
> It does not imply that they should urge on ioaddr.
> 
> drivers/net/ethernet/broadcom/tg3.c gets it right and there is no reason
> why sxgbe should be different.
> 
I fully understood.

> > As of now I think it is enough but I'll consider it later.
> 
> In the meantime:
> 1) more use-once function pointers are added
> 2) their parameter list keeps growing
> 
> Please reconsider sooner than later.
I'll revisit above things sooner (after this patch set).
Thanks.

> 
> --
> Ueimor
