From: David Miller <davem@davemloft.net>
Subject: Re: [Open-FCoE] [net-next-2.6 PATCH 5/5] fcoe: Use
 NETIF_F_FCOE_MTU flag to set up max frame size (lport->mfs)
Date: Thu, 23 Jul 2009 11:40:02 -0700 (PDT)
Message-ID: <20090723.114002.51085260.davem@davemloft.net>
References: <20090722232759.26937.78765.stgit@localhost.localdomain>
	<20090722232956.26937.24429.stgit@localhost.localdomain>
	<1248373648.23392.24.camel@fritz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, gospo@redhat.com, devel@open-fcoe.org
To: robert.w.love@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1248373648.23392.24.camel@fritz>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Love <robert.w.love@intel.com>
Date: Thu, 23 Jul 2009 11:27:28 -0700

> Please don't apply this patch to net-next. The other 4 patches in this
> series should be fine without it. If this patch is applied to net-next
> it means that most/all of the other fcoe features (that will go through
> linux-scsi) become dependent on this patch.
> 
> I was hoping to push the other fcoe features as-is and then push this
> patch through linux-scsi after the other 4 patches in this series had
> been merged by you.

Sure, I was just reading over this stuff.

But on the other hand, linux-scsi will be dependant upon net-next-2.6
because this patch here uses flags that will only be added there.

Therefore there has to be a dependency in one direction or another,
the question is which one works better for you FCOE guys.

The best thing to do in these situations is usually to create the
dependency and merge into the tree where most of the subsystem
specific bits (and thus developer ACKs) are needed.  And then
just occaisionally go and ask the other subsystem guys for ACKs
when necessary.

