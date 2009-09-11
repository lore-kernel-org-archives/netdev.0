From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Fri, 11 Sep 2009 21:46:02 +0100
Message-ID: <20090911204602.GA19371@shareable.org>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com> <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:56239 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbZIKUqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 16:46:05 -0400
Content-Disposition: inline
In-Reply-To: <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Paris wrote:
> > I would really prefer if you worked on eliminating the problem that
> > prevents you from using netlink instead.
> 
> I'm not really sure if I can, although I'd love to hear input from
> someone who knows the netlink code on how I can make it do what I need.
> I'm really not duplicating much other than the NLMSG_OK and NLMSG_NEXT
> macros.  My code doesn't even use skbs and I'm not savy enough to really
> know how I could.  I'm more than willing to work on it if someone can
> point me to how it might work.

Let's turn the question around.

Since you're doing lots of non-sockety things, and can't tolerate
dropped packets - why isn't it a character device?  What's the reason
for using a socket at all?

(I'm reminded of /dev/poll, /dev/epoll and /dev/inotify :-)

-- Jamie
