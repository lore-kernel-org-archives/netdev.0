From: Dan Aloni <da-x@gmx.net>
Subject: Re: [PATCH] network device renaming sysfs fix
Date: Fri, 15 Aug 2003 14:45:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815114507.GA5929@callisto.yi.org>
References: <E791C176A6139242A988ABA8B3D9B38A014C949E@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Net-Dev <netdev@oss.sgi.com>, "David S. Miller" <davem@redhat.com>,
   Mark Huth <mhuth@mvista.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
Content-Disposition: inline
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C949E@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2003 at 02:36:27PM +0300, Hen, Shmulik wrote:
> > -----Original Message-----
> > From: Dan Aloni [mailto:da-x@gmx.net]
> > Sent: Friday, August 15, 2003 2:15 PM
> > To: Linux Net-Dev
> > Cc: David S. Miller; Mark Huth
> > Subject: [PATCH] network device renaming sysfs fix
> > 
> > 
> > (repost, now will hopefully reach the mailing list)
> > 
> > I believe this is a better approach for fixing the sysfs renaming
> > discrepancy. Later I'll also look into fixing the same issue 
> > with sysctl.
> > 
> > 
> > -- 
> > Dan Aloni
> > da-x@gmx.net
> > 
> > 
> 
> In general, it a similar thing applicable for proc fs too ?
> We just had to fix something like that in bonding, and
> it sounds odd each driver should handle this on it's own.

It is more complicated. procfs's interface to sysctl is optional -
thus sysctl's interfaces hide procfs from you. Fixing this require 
changes in sysctl itself, and most probably also in the networking 
code, because network devices' sysctls are not exposed in the 
net/dev/core.c level.

-- 
Dan Aloni
da-x@gmx.net
