From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] net/hyperv: Advertise hv_netvsc instead of netvsc as
	driver name
Date: Wed, 7 Mar 2012 12:49:46 -0800
Message-ID: <20120307204946.GA4413@kroah.com>
References: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
	<20120307201746.GA20900@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20120307201746.GA20900@aepfle.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2012 at 09:17:46PM +0100, Olaf Hering wrote:
> On Wed, Mar 07, Haiyang Zhang wrote:
> 
> 
> > @@ -482,7 +484,7 @@ MODULE_DEVICE_TABLE(vmbus, id_table);
> >  
> >  /* The one and only one */
> >  static struct  hv_driver netvsc_drv = {
> > -	.name = "netvsc",
> > +	.name = MODULE_NAME,
> 
> It would be nice if this could be applied to 3.3.
> hv_storvsc and hid-hyperv already use the same naming, this patch was
> send last year already but was not applied for some reason.

What userspace tools depend on this that requires it to be in 3.3?

greg k-h
