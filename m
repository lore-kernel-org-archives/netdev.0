From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Sat, 12 Sep 2009 13:47:27 +0400
Message-ID: <20090912094727.GC24709@ioremap.net>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com> <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com> <1252704102.25158.36.camel@dogo.mojatatu.com> <20090911214254.GB19901@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Eric Paris <eparis@redhat.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org, balbir@in.ibm.com
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090911214254.GB19901@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2009 at 10:42:54PM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> While skbs and netlink aren't that slow, I suspect they're an order of
> magnitude or two slower than, say, epoll or inotify at passing events
> around.

Skbs are those tiny bits which allow 100 Gbit/s forwarding between multiple
interfaces. But of course it can not be as fast as plain memory copy :)

Having one skb allocation per IO syscall will be challenging but after
all we have this for send/recv calls and achieve high performance
numbers. Idea with merging events in the same skb will be also very non-trivial.

-- 
	Evgeniy Polyakov
