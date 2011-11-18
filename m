From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] xen-netfront: report link speed to ethtool
Date: Fri, 18 Nov 2011 19:10:31 +0000
Message-ID: <1321643431.2883.39.camel@bwh-desktop>
References: <20111118164805.GA14345@aepfle.de>
	 <1321638394.2883.32.camel@bwh-desktop>  <20111118184336.GA16027@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:49634 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab1KRTKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 14:10:35 -0500
In-Reply-To: <20111118184336.GA16027@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-18 at 19:43 +0100, Olaf Hering wrote:
> On Fri, Nov 18, Ben Hutchings wrote:
> 
> > On Fri, 2011-11-18 at 17:48 +0100, Olaf Hering wrote:
> > > The reported data refers to VMWare vmxnet.
> > NAK, we should not just make things up.
> 
> So how about removing veth_get_settings, vmxnet3_get_settings,
> tun_get_settings and other functions that escaped my grep?

If they can't provide meaningful information then maybe they should be
removed.  However, that could result in a regression for existing
working configurations.  (This isn't the same as the case you're trying
to fix, since those applications have never worked with xen-netfront or
many other drivers that don't implement get_settings.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
