From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Thu, 30 Jun 2016 16:22:12 +0000
Message-ID: <CY1PR03MB2186E874E6D0B48EEDF069BBBF240@CY1PR03MB2186.namprd03.prod.outlook.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
 <20160630161212.GA7456@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160630161212.GA7456@aepfle.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Olaf Hering [mailto:olaf@aepfle.de]
> Sent: Friday, July 1, 2016 0:12
> To: Dexuan Cui <decui@microsoft.com>
> Cc: davem@davemloft.net; gregkh@linuxfoundation.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; apw@canonical.com; jasowang@redhat.com;
> Vitaly Kuznetsov <vkuznets@redhat.com>; Cathy Avery <cavery@redhat.com>;
> KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; joe@perches.com; Rolf Neugebauer
> <rolf.neugebauer@docker.com>
> Subject: Re: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> 
> On Thu, Jun 30, Dexuan Cui wrote:
> 
> > -#define AF_MAX		43	/* For now.. */
> > +#define AF_MAX		44	/* For now.. */
> 
> Should this patch also change the places where AF_MAX is used,
> like all the arrays in net/core/sock.c?
> 
> Olaf

Thanks for the reminder, Olaf!

I think we may as well make a separate patch for this. 
It is in my To-Do list.

Thanks,
-- Dexuan
