From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: [CFT] 2.6.x experimental net driver updates
Date: Thu, 20 Nov 2003 02:54:23 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031120025423.GB24159@parcelfarce.linux.theplanet.co.uk>
References: <3FBBA954.6000601@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FBBA954.6000601@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2003 at 12:33:08PM -0500, Jeff Garzik wrote:
> Ok, Al Viro's net driver refcounting work is pretty much complete, and 

The hell it is.  We are through with legacy probes, we are through with
init_etherdev(), we are practically through with static struct net_device.

However, we still have weird allocators (I've got almost all of them
done by now, will submit in the next batch) and we still have struct
net_device embedded as a field of other structures in several drivers.

It's nowhere near as massive as legacy probes series, but it's going to
be 10--20 patches.  At least.
