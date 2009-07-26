From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH 5/5] fcoe: Use NETIF_F_FCOE_MTU
 flag to set up max frame size (lport->mfs)
Date: Sun, 26 Jul 2009 09:44:02 -0700 (PDT)
Message-ID: <20090726.094402.38463748.davem@davemloft.net>
References: <1248373648.23392.24.camel@fritz>
	<20090723.114002.51085260.davem@davemloft.net>
	<1248374883.23392.31.camel@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1248374883.23392.31.camel@fritz>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Thu, 23 Jul 2009 11:48:03 -0700

> Yes, absolutely, but it's only this small patch that creates the
> dependency. I figured that all of the other fcoe patches could go into
> James' scsi-misc tree and get merged first. Then this one could go into
> his scsi-post-merge tree and depend on net-next.
> 
> It's really up to you and James, I just thought that would be easier.

So I tried to apply just the networking bits but none of the ixgbe
parts apply properly to net-next-2.6, so this patch series will
need to be respun and resubmitted in it's entirety so I can
apply it properly.

It seems that the ixgbe driver now maintains feature flags differently
than whatever revision of the driver these patches were generated
against.
