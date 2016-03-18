From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: consolidate lock/unlock into unlock_wait
Date: Fri, 18 Mar 2016 15:35:18 -0700
Message-ID: <1458340518.26915.30.camel@perches.com>
References: <1458293525-16842-1-git-send-email-hofrat@osadl.org>
	 <20160318.173702.788700055531273267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160318.173702.788700055531273267.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-03-18 at 17:37 -0400, David Miller wrote:
> From: Nicholas Mc Guire <hofrat@osadl.org>
> > The spin_lock()/spin_unlock() is synchronizing on the adapter->work_lock
> > as the comment also suggests, which is equivalent to spin_unlock_wait()
> > but the later should be more efficient.
[]
> There really is no justification for this change.
> This is an optimization in a slow-path of the driver.
> The device is a rarely used older piece of hardware.

It really might be nice to take some of the ancient
hardware drivers in drivers/net and move them into
some separate subdirectory like:

	drivers/net/ancient
or
	drivers/net/antiques
or
	drivers/net/archaic
etc...

so there's some clear designation that these crufty
old drivers don't need to be touched anymore except
for maybe when kernel wide changes occur.
