From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v3] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Wed, 19 Mar 2014 21:36:24 +0000
Message-ID: <96538481deb64ee0a7fd511bedfa1d55@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1395180922-2776-1-git-send-email-haiyangz@microsoft.com>
 <20140319.164005.1815461875771862691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140319.164005.1815461875771862691.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> > +
> > +
> > +/* ndis_recv_scale_cap/cap_flag */
> 
> One empty line is sufficient, we don't need two of them here.

I will fix this and other formats you pointed out below, also check the whole patch 
for similar issues.

> > -	net = alloc_etherdev(sizeof(struct net_device_context));
> > +	net = alloc_etherdev_mq(sizeof(struct net_device_context),
> > +				num_online_cpus());
> >  	if (!net)
> >  		return -ENOMEM;
> >
> 
> num_online_cpus() can change, will your driver accomodate this?

HyperV currently doesn't support hot-add/remove cpu, so this is constant for 
this driver.

Thanks,
- Haiyang
