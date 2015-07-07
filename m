From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 7 Jul 2015 10:20:41 +0000
Message-ID: <cf30a808b461480d8c399e556ddef513@SIXPR30MB031.064d.mgd.msft.net>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
 <1436261876.20057.132.camel@tiscali.nl> <20150707101025.GA5003@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Olaf Hering <olaf@aepfle.de>, Paul Bolle <pebolle@tiscali.nl>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150707101025.GA5003@aepfle.de>
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
> From: Olaf Hering [mailto:olaf@aepfle.de]
> Sent: Tuesday, July 7, 2015 18:10
> To: Dexuan Cui; Paul Bolle
> Cc: gregkh@linuxfoundation.org; davem@davemloft.net;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org; apw@canonical.com; jasowang@redhat.com; KY
> Srinivasan; Haiyang Zhang
> Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
> 
> On Tue, Jul 07, Paul Bolle wrote:
> 
> > On ma, 2015-07-06 at 07:47 -0700, Dexuan Cui wrote:
> > > --- /dev/null
> > > +++ b/net/hv_sock/Kconfig
> >
> > > +config HYPERV_SOCK
> > > +	tristate "Microsoft Hyper-V Socket (EXPERIMENTAL)"
> > > +	depends on HYPERV
> > > +	default m
> 
> > It's a bit odd to advise to say N if one is unsure and set the default
> > to 'm' at the same time.
> 
> The 'default' line has to be removed IMO.
> 
> Olaf

OK, removing the line seems better than 'default n', though both reproduce
the same "# CONFIG_HYPERV_SOCK is not set".

-- Dexuan
