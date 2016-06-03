From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V3 0/2] vhost_net polling optimization
Date: Fri, 3 Jun 2016 16:03:25 +0300
Message-ID: <20160603160259-mutt-send-email-mst@redhat.com>
References: <1464760594-30326-1-git-send-email-jasowang@redhat.com>
 <20160602.120806.2233781548139724198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160602.120806.2233781548139724198.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 12:08:06PM -0700, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed,  1 Jun 2016 01:56:32 -0400
> 
> > This series tries to optimize vhost_net polling at two points:
> > 
> > - Stop rx polling for reduicng the unnecessary wakeups during
> >   handle_rx().
> > - Conditonally enable tx polling for reducing the unnecessary
> >   traversing and spinlock touching.
> > 
> > Test shows about 17% improvement on rx pps.
> > 
> > Please review
> > 
> > Changes from V2:
> > - Don't enable rx vq if we meet an err or rx vq is empty
> > Changes from V1:
> > - use vhost_net_disable_vq()/vhost_net_enable_vq() instead of open
> >   coding.
> > - Add a new patch for conditionally enable tx polling.
> 
> Michael, please review this patch series.
> 
> Thanks.

thanks for the reminder, I plan to review next week.
