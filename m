From: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>
Subject: RE: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 02:45:19 +0000
Message-ID: <DC7803B42427924284F2D5252E076A3B44769DDC@SINEX14MBXC416.southpacific.corp.microsoft.com>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <53C8F332.8010604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Shao <huishao@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>
To: Varka Bhadram <varkabhadram@gmail.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "jasowang@redhat.com" <jasowang@redhat.com>, "davem@davemloft.net"
 <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <53C8F332.8010604@gmail.com>
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

> From: Varka Bhadram [mailto:varkabhadram@gmail.com]
> Sent: Friday, July 18, 2014 6:13 PM
> 
> On 07/18/2014 04:25 PM, Yue Zhang wrote:
> > @@ -816,8 +816,21 @@ static void netvsc_link_change(struct work_struct
> *w)
> >
> >   	rtnl_unlock();
> >
> > -	if (refresh)
> > -		call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
> > +	if (refresh) {
> > +		/*
> > +		 * Keep the carrier offline for 10 seconds
> > +		 * to notify ifplugd daemon network change
> > +		 */
> 
> This should be networking comment style..
> 
> 	/* bla bla..
> 	 * bla
> 	 */
> 
> --
> Regards,
> Varka Bhadram.

I will fix this.

Thanks
Yue
