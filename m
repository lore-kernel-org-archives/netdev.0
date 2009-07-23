From: Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH 5/5] fcoe: Use NETIF_F_FCOE_MTU
 flag to set up max frame size (lport->mfs)
Date: Thu, 23 Jul 2009 11:48:03 -0700
Message-ID: <1248374883.23392.31.camel@fritz>
References: <20090722232759.26937.78765.stgit@localhost.localdomain>
	<20090722232956.26937.24429.stgit@localhost.localdomain>
	<1248373648.23392.24.camel@fritz>
	<20090723.114002.51085260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <20090723.114002.51085260.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Thu, 2009-07-23 at 11:40 -0700, David Miller wrote:
> From: Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date: Thu, 23 Jul 2009 11:27:28 -0700
> 
> > Please don't apply this patch to net-next. The other 4 patches in this
> > series should be fine without it. If this patch is applied to net-next
> > it means that most/all of the other fcoe features (that will go through
> > linux-scsi) become dependent on this patch.
> > 
> > I was hoping to push the other fcoe features as-is and then push this
> > patch through linux-scsi after the other 4 patches in this series had
> > been merged by you.
> 
> Sure, I was just reading over this stuff.
> 
> But on the other hand, linux-scsi will be dependant upon net-next-2.6
> because this patch here uses flags that will only be added there.
> 
Yes, absolutely, but it's only this small patch that creates the
dependency. I figured that all of the other fcoe patches could go into
James' scsi-misc tree and get merged first. Then this one could go into
his scsi-post-merge tree and depend on net-next.

It's really up to you and James, I just thought that would be easier.

> Therefore there has to be a dependency in one direction or another,
> the question is which one works better for you FCOE guys.
> 
> The best thing to do in these situations is usually to create the
> dependency and merge into the tree where most of the subsystem
> specific bits (and thus developer ACKs) are needed.  And then
> just occaisionally go and ask the other subsystem guys for ACKs
> when necessary.
> 
> _______________________________________________
> devel mailing list
> devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
> http://www.open-fcoe.org/mailman/listinfo/devel
