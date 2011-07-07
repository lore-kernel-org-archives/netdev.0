From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V8 0/4 net-next] macvtap/vhost TX zero-copy support
Date: Thu, 07 Jul 2011 04:08:40 -0700 (PDT)
Message-ID: <20110707.040840.809661052978541081.davem@davemloft.net>
References: <1309990525.10209.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309990525.10209.12.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <mashirle@us.ibm.com>
Date: Wed, 06 Jul 2011 15:15:25 -0700

> This patchset add supports for TX zero-copy between guest and host
> kernel through vhost. It significantly reduces CPU utilization on the
> local host on which the guest is located (It reduced about 50% CPU usage
> for single stream test on the host, while 4K message size BW has
> increased about 50%). The patchset is based on previous submission and
> comments from the community regarding when/how to handle guest kernel
> buffers to be released. This is the simplest approach I can think of
> after comparing with several other solutions.
> 
> This patchset has integrated V3 review comments from community: 

I'm personally fine with this patch set.  Unless there are others
who object, please fix the use-after-free bug I reported, respin
the patch set, and I'll apply it.

Thanks.
