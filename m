From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] vhost: rcu annotation fixup
Date: Wed, 19 Jan 2011 00:40:40 +0000
Message-ID: <20110119004040.GE18984@csn.ul.ie>
References: <20110118110845.GA11555@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110118110845.GA11555@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2011 at 01:08:45PM +0200, Michael S. Tsirkin wrote:
> When built with rcu checks enabled, vhost triggers
> bogus warnings as vhost features are read without
> dev->mutex sometimes.
> Fixing it properly is not trivial as vhost.h does not
> know which lockdep classes it will be used under.
> Disable the warning by stubbing out the check for now.
> 

What is the harm in leaving the bogus warnings until the difficult fix
happens? RCU checks enabled does not seem like something that is enabled
in production. If this patch is applied, there is always the risk that
it'll be simply forgotten about.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
