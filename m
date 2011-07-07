From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V8 0/4 net-next] macvtap/vhost TX zero-copy support
Date: Thu, 7 Jul 2011 14:37:15 +0300
Message-ID: <20110707113715.GA32632@redhat.com>
References: <1309990525.10209.12.camel@localhost.localdomain>
 <20110707.040840.809661052978541081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mashirle@us.ibm.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110707.040840.809661052978541081.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 07, 2011 at 04:08:40AM -0700, David Miller wrote:
> From: Shirley Ma <mashirle@us.ibm.com>
> Date: Wed, 06 Jul 2011 15:15:25 -0700
> 
> > This patchset add supports for TX zero-copy between guest and host
> > kernel through vhost. It significantly reduces CPU utilization on the
> > local host on which the guest is located (It reduced about 50% CPU usage
> > for single stream test on the host, while 4K message size BW has
> > increased about 50%). The patchset is based on previous submission and
> > comments from the community regarding when/how to handle guest kernel
> > buffers to be released. This is the simplest approach I can think of
> > after comparing with several other solutions.
> > 
> > This patchset has integrated V3 review comments from community: 
> 
> I'm personally fine with this patch set.  Unless there are others
> who object, please fix the use-after-free bug I reported, respin
> the patch set, and I'll apply it.
> 
> Thanks.

There's the FIXME in patch 4 where it spins in vhost waiting for
the pages to get freed. I'm fixing that up as Shirley's on vacation.

Apply patches 1-3 for now?

-- 
MST
