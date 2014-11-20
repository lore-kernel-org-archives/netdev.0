From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: mlx5: don't duplicate kvfree()
Date: Thu, 20 Nov 2014 18:51:09 +0000
Message-ID: <20141120185108.GP7996@ZenIV.linux.org.uk>
References: <20141120081357.GI7996@ZenIV.linux.org.uk>
 <20141120081726.GK7996@ZenIV.linux.org.uk>
 <546E204B.5080106@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <546E204B.5080106-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2014 at 07:09:31PM +0200, Or Gerlitz wrote:
> On 11/20/2014 10:17 AM, Al Viro wrote:
> >On Thu, Nov 20, 2014 at 08:13:57AM +0000, Al Viro wrote:
> >>>  9 files changed, 21 insertions(+), 35 deletions(-)
> >grr... 8 files changed, actually - that was from the diff that included mlx4
> >bits.  Patch split correctly and sent in two pieces, summary left as is ;-/
> >Sorry about the confusion it might cause...
> Al,
> 
> I think the best way to proceed here is to come up with mlx4 and
> mlx5 patches and get both of them in through netdev / net-nexttree,
> don't worry about each of these drivers have a part which is also
> under drivers/infiniband/hw -- it doesn't justify splitting in this
> case

Both had been sent to netdev today (and ACKed by respective drivers'
maintainers).  I'd certainly prefer not to put them through vfs.git,
but beyond that I really don't care which tree do those go into...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
