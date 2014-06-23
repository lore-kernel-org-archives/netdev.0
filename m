From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Mon, 23 Jun 2014 20:17:39 +0000
Message-ID: <83e9c73eb6914fb59f88de7c8570017d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <06b508cbb6b949f4b3e13e7797948e56@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<20140623131723.GA7026@aepfle.de>
	<5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623.131018.1349792926453695313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
	"greg@kroah.com" <greg@kroah.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140623.131018.1349792926453695313.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, June 23, 2014 4:10 PM
> To: Haiyang Zhang
> Cc: olaf@aepfle.de; greg@kroah.com; netdev@vger.kernel.org;
> jasowang@redhat.com; driverdev-devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH net-next] hyperv: Add handler for
> RNDIS_STATUS_NETWORK_CHANGE event
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Mon, 23 Jun 2014 16:09:59 +0000
> 
> > So, what's the equivalent or similar command to "network restart" on
> > SLES12? Could you update the command line for the usermodehelper when
> > porting this patch to SLES 12?
> 
> No, you are not going to keep the usermodehelper invocation in your driver
> please remove it.  It is absolutely inappropriate, and I strictly do not want to
> keep it in there because other people will copy it and then we'll have a real
> mess on our hands.

I'm working on it, and will have a patch to replace the usermodehelper soon.

Thanks,
- Haiyang
