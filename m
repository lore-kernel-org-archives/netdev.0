From: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Subject: RE: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 05:47:46 +0000
Message-ID: <9ca0175d05e14360bc1dfdd161db9241@BY2PR03MB524.namprd03.prod.outlook.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
 <543DFF2C.40306@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <543DFF2C.40306@hartkopp.net>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Oliver Hartkopp [mailto:socketcan@hartkopp.net]
> Sent: Wednesday, October 15, 2014 12:59 PM
> To: Pan Jiafei-B37022; davem@davemloft.net; jkosina@suse.cz
> Cc: netdev@vger.kernel.org; Li Yang-Leo-R58472; linux-doc@vger.kernel.org
> Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
> 
> On 15.10.2014 05:26, Pan Jiafei wrote:
> > In some platform, there are some hardware block provided
> > to manage buffers to improve performance.
> 
> (..)
[Pan Jiafei] I want to build a general patch to build skb
by using hardware buffer manager block.
> 
> > diff --git a/net/Kconfig b/net/Kconfig
> > index d6b138e..346e021 100644
> > --- a/net/Kconfig
> > +++ b/net/Kconfig
> > @@ -291,6 +291,16 @@ config NET_FLOW_LIMIT
> >   	  with many clients some protection against DoS by a single (spoofed)
> >   	  flow that greatly exceeds average workload.
> >
> > +config USE_HW_SKB
> > +	bool "NIC use hardware managed buffer to build skb"
> > +	depends on INET
> 
> The feature seems to be valid for network devices in general.
> Why did you make it depending on INET ??
> 
> Regards,
> Oliver
> 
[Pan Jiafei] Yes, INET dependency should be removed, thanks.
> > +	---help---
> > +	  If select this, the third party drivers will use hardware managed
> > +	  buffers to allocate SKB without any modification for the driver.
> > +
> > +	  Documentation on how to use this featue can be found at
> > +	  <file:Documentation/networking/hw_skb.txt>.
> > +
> >   menu "Network testing"
> >
> >   config NET_PKTGEN

