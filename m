From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Steps for netdev-2.6 inclusion?
Date: Fri, 3 Dec 2004 10:33:39 +0000
Message-ID: <20041203103339.GB10799@infradead.org>
References: <41AE7143.80505@linux.intel.com> <41AEB3B8.2000406@pobox.com> <41AF7708.3030804@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <41AF7708.3030804@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 02, 2004 at 02:11:52PM -0600, James Ketrenos wrote:
> Jeff Garzik wrote:
> 
> >It's fairly easy, just email me and netdev the patch for inclusion, 
> >and it'll get reviewed.
> 
> Should I break the patch into the three components (ipw2100, ipw2200, 
> and ieee80211) ? or just one huge patch?  Not sure what you and others 
> would prefer.

Please split it in three parts.  And most importantly integrate your
ieee80211 code with the hostap code in Jeff's queue, we really don't
want two copies of it.

> The firmware doesn't have to be downloaded from Sourceforge, but it does 
> need to exist on the system, just as iwconfig needs to exist if you want 
> to be able to configure your wireless card.  The user can get the 
> firmware from Sourceforge, or have it installed by their distribution or 
> package management system, have it on their Knoppix CD, etc. 

The problem is again that the license for it is horrible multi page
legaleese.  Please change it to a simple license that allows completely
free redistribution and modification of the binaries.
