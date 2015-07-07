From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 7 Jul 2015 10:02:55 +0000
Message-ID: <1e0b3449110c487d8ed033c6f853285a@SIXPR30MB031.064d.mgd.msft.net>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
 <1436261876.20057.132.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1436261876.20057.132.camel@tiscali.nl>
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

> -----Original Message-----
> From: Paul Bolle
> Sent: Tuesday, July 7, 2015 17:38
> To: Dexuan Cui
> Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
> 
> Just two nits.
> 
> On ma, 2015-07-06 at 07:47 -0700, Dexuan Cui wrote:
> > --- /dev/null
> > +++ b/net/hv_sock/Kconfig
> 
> > +config HYPERV_SOCK
> > +	tristate "Microsoft Hyper-V Socket (EXPERIMENTAL)"
> > +	depends on HYPERV
> > +	default m
> > +	help
> > +	  Hyper-V Socket is a socket protocol similar to TCP, allowing
> > +	  communication between a Linux guest and the host.
> > +
> > +	  To compile this driver as a module, choose M here: the module
> > +	  will be called hv_sock. If unsure, say N.
> 
> It's a bit odd to advise to say N if one is unsure and set the default
> to 'm' at the same time.
Hi Paul,
Thanks for the suggestion!
I'll change the 'default' to n in V2.

> > --- /dev/null
> > +++ b/net/hv_sock/af_hvsock.c
> 
> > +static int hvsock_init(void)
> > +{
> > +	[...]
> > +}
> > +
> > +static void hvsock_exit(void)
> > +{
> > +	[...]
> > +}
> > +
> > +module_init(hvsock_init);
> > +module_exit(hvsock_exit);
> 
> Any specific reason not to mark these functions __init and __exit?
> 
> Paul Bolle
Thanks for pointing this out -- I missed that. 
I'll add __init and __exit in V2.

Thanks,
-- Dexuan
