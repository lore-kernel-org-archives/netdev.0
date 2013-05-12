From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [RFC 17/42] drivers/net/ethernet/renesas: don't check resource
 with devm_ioremap_resource
Date: Sun, 12 May 2013 18:32:51 +0200
Message-ID: <20130512163246.GA2928@katana>
References: <1368173847-5661-1-git-send-email-wsa@the-dreams.de>
 <1368173847-5661-18-git-send-email-wsa@the-dreams.de>
 <518EAB9B.8040106@cogentembedded.com>
 <20130512094202.GA3039@katana>
 <518FB49B.7030708@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <518FB49B.7030708@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>    You can always try to do:
> 
> $ make drivers/net/ethernet/renesas/sh_eth.o
> 
> with a .config file you have. It will compile a file regardless of
> whether it's enabled in your .config or not...

Been there. This mainly works for platform independent drivers. In this case:

  CC      drivers/net/ethernet/renesas/sh_eth.o
drivers/net/ethernet/renesas/sh_eth.c: In function 'sh_eth_dev_init':
drivers/net/ethernet/renesas/sh_eth.c:1274:2: error: implicit declaration of function 'sh_eth_reset' [-Werror=implicit-function-declaration]
drivers/net/ethernet/renesas/sh_eth.c: In function 'sh_eth_drv_probe':
drivers/net/ethernet/renesas/sh_eth.c:2724:13: error: 'sh_eth_my_cpu_data' undeclared (first use in this function)
drivers/net/ethernet/renesas/sh_eth.c:2724:13: note: each undeclared identifier is reported only once for each function it appears in
drivers/net/ethernet/renesas/sh_eth.c: At top level:
drivers/net/ethernet/renesas/sh_eth.c:889:12: warning: 'sh_eth_check_reset' defined but not used [-Wunused-function]

> >That being said, the actual mistake I did was embarassing, I agree. I am
> >sorry for that and will improve. And, doing things means doing mistakes,
> >too.
> 
>    Be more attentive in the future please. :-)

Sure thing.

Regards,

   Wolfram
