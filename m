From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v2,1/1] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Mon, 17 Mar 2014 20:59:33 +0000
Message-ID: <00f34d2e88ab447bb13e0a19af3cf816@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1394903887-30421-1-git-send-email-haiyangz@microsoft.com>
 <1394903887-30421-2-git-send-email-haiyangz@microsoft.com>
 <1395088079.22343.6.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1395088079.22343.6.camel@deadeye.wl.decadent.org.uk>
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
> From: Ben Hutchings [mailto:ben@decadent.org.uk]
> Sent: Monday, March 17, 2014 4:28 PM
> To: Haiyang Zhang
> Cc: davem@davemloft.net; netdev@vger.kernel.org; KY Srinivasan;
> olaf@aepfle.de; jasowang@redhat.com; linux-kernel@vger.kernel.org;
> driverdev-devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,v2,1/1] hyperv: Add support for virtual Receive
> Side Scaling (vRSS)
> 
> On Sat, 2014-03-15 at 10:18 -0700, Haiyang Zhang wrote:
> [...]
> >  #define RING_SIZE_MIN 64
> > -static int ring_size = 128;
> > +int ring_size = 128;
> >  module_param(ring_size, int, S_IRUGO);  MODULE_PARM_DESC(ring_size,
> > "Ring buffer size (# of pages)");
> 
> You have to add some driver-specific prefix to the variable name if it is going to
> be extern.  (And use module_param_named to avoid changing the parameter
> name too.)
> 
> [...]
> > +u8 hash_key[HASH_KEYLEN] = {
> > +	0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2,
> > +	0x41, 0x67, 0x25, 0x3d, 0x43, 0xa3, 0x8f, 0xb0,
> > +	0xd0, 0xca, 0x2b, 0xcb, 0xae, 0x7b, 0x30, 0xb4,
> > +	0x77, 0xcb, 0x2d, 0xa3, 0x80, 0x30, 0xf2, 0x0c,
> > +	0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa };
> [...]
> 
> Same for this one.
> 
I will do.

Thanks,
- Haiyang
