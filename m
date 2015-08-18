From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Tue, 18 Aug 2015 11:28:26 +0200
Message-ID: <20150818092826.GB4563@unicorn.suse.cz>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <55CD8DDB.5080001@cumulusnetworks.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E2389@SJEXCHMB14.corp.ad.broadcom.com>
 <9B0331B6EBBD0E4684FBFAEDA55776F919413D1D@HASMSX110.ger.corp.intel.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E2730@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rosen, Rami" <rami.rosen@intel.com>,
	roopa <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47378 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbbHRJ2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 05:28:31 -0400
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E2730@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 09:08:42AM +0000, Premkumar Jonnala wrote:
> > -----Original Message-----
> > From: Rosen, Rami [mailto:rami.rosen@intel.com]
> > Sent: Tuesday, August 18, 2015 10:25 AM
> > To: Premkumar Jonnala; roopa
> > Cc: netdev@vger.kernel.org
> > Subject: RE: [PATCH] bridge: Enable configuration of ageing interval for bridges
> > and switch devices.
> > 
> > Hi,
> > 
> > First, I agree about the need to propagate the ageing interval to switchdev
> > devices, so that hardware based aging can be setup correctly.
> > 
> > Second, in this occasion, I want to mention the need to
> > turn off bridge ageing in the kernel as part of using switchdev devices. This is
> > mentioned in
> > https://kernel.googlesource.com/pub/scm/linux/kernel/git/davem/net-
> > next/+/master/Documentation/networking/switchdev.txt:
> > 
> > ...
> > XXX: how to turn off ageing in kernel on a per-port basis or
> > otherwise prevent the kernel from ageing out the FDB entry?
> > ...
> > 
> > One can think of the option of using value 0 of the ageing interval as an
> > indication to turn off bridge ageing in the kernel, and any other value bigger
> > than MIN_AGEING_INTERVAL_SECS to turn on bridge ageing.
> 
> I recall that there was a patch proposed to prevent ageing of fdb entried by bridge in kernel,
> when the fdb entry was added due to notification by switch device.  Please see:
> http://www.spinics.net/lists/netdev/msg314770.html
> 
> Somehow the patch is not visible in the net-next pull.

It has been reverted by commit 3fcf90111887 as requested by

  http://www.spinics.net/lists/netdev/msg315236.html

Michal Kubecek
