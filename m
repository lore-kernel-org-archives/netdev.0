From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] net: export device speed and duplex via sysfs
Date: Fri, 2 Oct 2009 16:01:41 -0400
Message-ID: <20091002200141.GB1639@gospo.rdu.redhat.com>
References: <20091002180742.GH4436@gospo.rdu.redhat.com> <1254507554.8795.12.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756813AbZJBUBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 16:01:39 -0400
Content-Disposition: inline
In-Reply-To: <1254507554.8795.12.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 02, 2009 at 07:19:14PM +0100, Ben Hutchings wrote:
> On Fri, 2009-10-02 at 14:07 -0400, Andy Gospodarek wrote:
> > This exports the link-speed (in Mbps) and duplex of an interface via
> > sysfs.  This eliminates the need to use ethtool just to check the
> > link-speed.  Not requiring 'ethtool' and not relying on the SIOCETHTOOL
> > ioctl should be helpful in an embedded environment where space is at a
> > premium as well.
> 
> It's trivial to write an ethtool-lite that does this.  That might be
> worth adding to busybox.
> 

It probably would be.  I was just using this as an example of another
use for it.  Embedded usage was not the primary purpose.

> > NOTE: This patch also intentionally allows non-root users to check the link
> > speed and duplex -- something not possible with ethtool.
> [...]
> 
> Assuming this is desirable (I'm not sure), wouldn't it would make more
> sense to move the permissions check for SIOCETHTOOL so that get_settings
> is non-privileged?
> 

That could be done as well I just chose to go a slightly different
direction.

I took a look at /sys/class/net/ethX/ and felt like the information was
pretty complete with the exception of the link speed and duplex, so I
thought it would be a good place to add it.  I personally wouldn't mind
having most of the information presented in ethtool available via sysfs,
but I figured I would walk before running.

