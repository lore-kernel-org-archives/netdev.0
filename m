From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: randconfig build error with next-20140502, in
 drivers/net/hyperv/netvsc_drv.c
Date: Fri, 2 May 2014 19:30:25 +0000
Message-ID: <23526aafab1c4c3a984240bb56b38a19@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <CA+r1ZhhAdRwEFE3u4E1QQiCSa6Cz5Onhy1iVJHhzB4dUiEOL4g@mail.gmail.com>
	<91a4eac99889460f91f619385208cbca@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140502.151927.359156056899842119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jim.epost@gmail.com" <jim.epost@gmail.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140502.151927.359156056899842119.davem@davemloft.net>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, May 2, 2014 3:19 PM
> To: Haiyang Zhang
> Cc: jim.epost@gmail.com; sfr@canb.auug.org.au; linux-
> next@vger.kernel.org; linux-kernel@vger.kernel.org; KY Srinivasan;
> devel@linuxdriverproject.org; netdev@vger.kernel.org
> Subject: Re: randconfig build error with next-20140502, in
> drivers/net/hyperv/netvsc_drv.c
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Fri, 2 May 2014 14:42:06 +0000
> 
> > real_num_rx_queues is defined in "include/linux/netdevice.h":
> > It requires CONFIG_SYSFS flag, which is enabled by default, but not
> set in
> > your config file.
> >
> > Could you use default config and add hyperv drivers, then try again?
> 
> You must fix your driver to compile successfully under all possible
> configuration combinations, not just the ones which are convenient
> for you to support.

OK, I'll look into this.

Thanks,
- Haiyang
