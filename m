From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Mon, 23 Jun 2014 18:21:13 +0000
Message-ID: <4ee8be5360a44b5abfa6df871ec45527@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620045704.GA4850@aepfle.de> <20140620051213.GA9960@kroah.com>
 <ff458d1b896d4a70a32fa7709911274c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623080242.GA16924@aepfle.de>
 <06b508cbb6b949f4b3e13e7797948e56@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623131723.GA7026@aepfle.de>
 <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623162705.GA5957@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140623162705.GA5957@aepfle.de>
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
> From: Olaf Hering [mailto:olaf@aepfle.de]
> Sent: Monday, June 23, 2014 12:27 PM
> To: Haiyang Zhang
> Cc: Greg KH; netdev@vger.kernel.org; jasowang@redhat.com; driverdev-
> devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> davem@davemloft.net
> Subject: Re: [PATCH net-next] hyperv: Add handler for
> RNDIS_STATUS_NETWORK_CHANGE event
> 
> On Mon, Jun 23, Haiyang Zhang wrote:
> 
> > I have tried some possibilities, like IF_OPER_DORMANT then IF_OPER_UP
> > with
> > netdev_state_change() etc. but not able to trigger DHCP review. I will
> > look at this further...
> 
> Is there a link down/up event anyway?
> If the interface is configured to "on hotplug" or "on cable plugged in"
> or whatever the setting name is, the network scripts should do something. Even
> if its not a DHCP renew.

Yes, there is a link down/up event from the host, we currently call netif_carrier_off() 
/ netif_carrier_on() with these events. Will hotplug scripts be triggered by 
netif_carrier_off/on? Where are the scripts located at (SLES)?

> 
> > So, what's the equivalent or similar command to "network restart" on
> > SLES12? Could you update the command line for the usermodehelper when
> > porting this patch to SLES 12?
> 
> I see a /sbin/rcnetwork in SLES, which links either to '/etc/init.d/network' or
> 'service'. This could be used as a quick workaround.

Thanks for the info!

Thanks,
- Haiyang
