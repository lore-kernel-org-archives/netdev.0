From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] staging: hv: move hv_netvsc out of staging area
Date: Fri, 14 Oct 2011 19:40:58 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC096F80AF@TK5EX14MBXC227.redmond.corp.microsoft.com>
References: <1318620026-8349-1-git-send-email-haiyangz@microsoft.com>
 <1318620950.31522.9.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"gregkh@suse.de" <gregkh@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
	"Mike Sterling" <Mike.Sterling@microsoft.com>,
	NetDev <netdev@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318620950.31522.9.camel@lappy>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Sasha Levin [mailto:levinsasha928@gmail.com]
> Sent: Friday, October 14, 2011 3:36 PM
> > +
> > +obj-$(CONFIG_HYPERV_NET) += hyperv/
> > diff --git a/drivers/net/hyperv/Kconfig b/drivers/net/hyperv/Kconfig
> > new file mode 100644
> > index 0000000..936968d
> > --- /dev/null
> > +++ b/drivers/net/hyperv/Kconfig
> > @@ -0,0 +1,5 @@
> > +config HYPERV_NET
> > +	tristate "Microsoft Hyper-V virtual network driver"
> > +	depends on HYPERV
> 
> It doesn't depend on NET anymore?

All drivers in drivers/net depends on NET, which is handled by net/Kconfig 
already. So we don't need to duplicate the dependency. (suggested by Randy 
Dunlap <randy.dunlap@oracle.com> in last review.)

Thanks,
- Haiyang
