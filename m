From: Michael Mueller <mimu@linux.vnet.ibm.com>
Subject: Re: [PATCH v1] vhost: avoid large order allocations
Date: Wed, 14 May 2014 10:11:15 +0200
Message-ID: <20140514101115.4b7ffd69@bee>
References: <1399970133-46783-1-git-send-email-mimu@linux.vnet.ibm.com>
	<1399970133-46783-2-git-send-email-mimu@linux.vnet.ibm.com>
	<20140513084049.GE29442@redhat.com>
	<87tx8tg3a1.fsf@kima.orebokech.com>
	<20140513151527.GA28517@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Romain Francoise <romain@orebokech.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, borntraeger@de.ibm.com,
	cornelia.huck@de.ibm.com, ddongch@cn.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140513151527.GA28517@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 May 2014 18:15:27 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Tue, May 13, 2014 at 04:29:58PM +0200, Romain Francoise wrote:
> > "Michael S. Tsirkin" <mst@redhat.com> writes:
> > 
> > > Please dont' do this, extra indirection hurts performance.
> > > Instead, please change vhost_net_open and scsi to allocate the whole
> > > structure with vmalloc if kmalloc fails, along the lines of
> > > 74d332c13b2148ae934ea94dac1745ae92efe8e5
> > 
> > Back in January 2013, you didn't seem to think it was a good idea:
> > 
> > https://lkml.org/lkml/2013/1/23/492
> 
> Hmm true, and Dave thought the structure's too large.
> I'll have to do some benchmarks to see what the effect
> of Michael's patch is, performance-wise.
> If it's too expensive I can pick up your patch, no need to
> repost.
> 

Thanks, let us know then.
