From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] net/hyperv: Advertise hv_netvsc instead of netvsc as
 driver name
Date: Thu, 8 Mar 2012 10:45:45 -0800
Message-ID: <20120308184545.GA1100@kroah.com>
References: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
 <20120307201746.GA20900@aepfle.de>
 <20120307204946.GA4413@kroah.com>
 <20120308061615.GA25237@aepfle.de>
 <20120308155219.GC5907@kroah.com>
 <20120308161221.GA31415@aepfle.de>
 <20120308174220.GB17192@kroah.com>
 <20120308183820.GA25015@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41651 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752813Ab2CHSps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 13:45:48 -0500
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id E9D4921194
	for <netdev@vger.kernel.org>; Thu,  8 Mar 2012 13:45:46 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20120308183820.GA25015@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 08, 2012 at 07:38:20PM +0100, Olaf Hering wrote:
> On Thu, Mar 08, Greg KH wrote:
> 
> > On Thu, Mar 08, 2012 at 05:12:21PM +0100, Olaf Hering wrote:
> > > On Thu, Mar 08, Greg KH wrote:
> > > 
> > > > > hwinfo uses it to recognize a network interface (storage in case of
> > > > > hv_storvsc).
> > > > 
> > > > That tool should report the real module name, not rely on the name to
> > > > match based on the structure, if you really care about the real module
> > > > name.
> > > 
> > > Its about the driver symlink, not the module name. 
> > > 
> > > I think most, if not all, (relevant) drivers use some sort of
> > > KBUILD_MODNAME. Why should this driver be any different?
> > 
> > It shouldn't, I'm not saying that at all.  I'm only objecting to the
> > insistance that this be something worthwhile for 3.3-final which should
> > be out any day now.
> 
> Since its an API we could settle on the new string, which is already in
> distro use.

I don't really understand, but in the end, it's not up to me, it's up to
the network maintainer when he wants to merge this to Linus.  If it were
up to me, I would wait for 3.4.

good luck,

greg k-h
