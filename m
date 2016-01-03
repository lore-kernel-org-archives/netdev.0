From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V5 4/9] Drivers: hv: ring_buffer: enhance
 hv_ringbuffer_read() to support hvsock
Date: Sun, 3 Jan 2016 11:55:35 +0000
Message-ID: <464cd084f1a0499587c91ea5b0e75b09@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1450966476-13175-1-git-send-email-decui@microsoft.com>
 <20160101.232952.740480728119960077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160101.232952.740480728119960077.davem@davemloft.net>
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
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, January 2, 2016 12:30
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; stephen@networkplumber.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com; KY Srinivasan <kys@microsoft.com>; pebolle@tiscali.nl;
> stefanha@redhat.com; vkuznets@redhat.com; dan.carpenter@oracle.com
> Subject: Re: [PATCH V5 4/9] Drivers: hv: ring_buffer: enhance
> hv_ringbuffer_read() to support hvsock
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Thu, 24 Dec 2015 06:14:36 -0800
> 
> > +#define HV_RINGBUFFER_READ_FLAG_RAW		(1 << 0)
> > +#define HV_RINGBUFFER_READ_FLAG_HVSOCK		(1 << 1)
> 
> Please use BIT().

Hi David, 
Thanks for the suggestion!  I'll fix it.

-- Dexuan
