From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH] net/hyperv: Advertise hv_netvsc instead of netvsc as
 driver name
Date: Thu, 8 Mar 2012 19:38:20 +0100
Message-ID: <20120308183820.GA25015@aepfle.de>
References: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
 <20120307201746.GA20900@aepfle.de>
 <20120307204946.GA4413@kroah.com>
 <20120308061615.GA25237@aepfle.de>
 <20120308155219.GC5907@kroah.com>
 <20120308161221.GA31415@aepfle.de>
 <20120308174220.GB17192@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120308174220.GB17192@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, Greg KH wrote:

> On Thu, Mar 08, 2012 at 05:12:21PM +0100, Olaf Hering wrote:
> > On Thu, Mar 08, Greg KH wrote:
> > 
> > > > hwinfo uses it to recognize a network interface (storage in case of
> > > > hv_storvsc).
> > > 
> > > That tool should report the real module name, not rely on the name to
> > > match based on the structure, if you really care about the real module
> > > name.
> > 
> > Its about the driver symlink, not the module name. 
> > 
> > I think most, if not all, (relevant) drivers use some sort of
> > KBUILD_MODNAME. Why should this driver be any different?
> 
> It shouldn't, I'm not saying that at all.  I'm only objecting to the
> insistance that this be something worthwhile for 3.3-final which should
> be out any day now.

Since its an API we could settle on the new string, which is already in
distro use.

Olaf
