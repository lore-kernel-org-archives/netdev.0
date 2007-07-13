From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Fri, 13 Jul 2007 11:03:22 +0400
Message-ID: <20070713070321.GA10361@2ka.mipt.ru>
References: <20070711210137.GE24114@agk.fab.redhat.com> <20070711142712.e646995b.akpm@linux-foundation.org> <20070712231920.GZ11166@waste.org> <20070712163115.ee686f8d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Matt Mackall <mpm@selenic.com>, Alasdair G Kergon <agk@redhat.com>,
	dm-devel@redhat.com, linux-kernel@vger.kernel.org,
	Mike Anderson <andmike@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35414 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933182AbXGMHFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 03:05:05 -0400
Content-Disposition: inline
In-Reply-To: <20070712163115.ee686f8d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 04:31:15PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > > Need a dependency on NET there?
> > 
> > It's really sad to make DM dependent on the network layer.
> > 
> 
> Yes, it would be somewhat sad.  However one can presumably continue to use
> DM, just without "DM netlink events".

On my machine device mapper (lvm, raid) does not work without sockets,
(maybe not dm, but hotplug, which creates nodes, or configuration)
so it already depends on it. Hotplug depends on networking.

You missed the day when everyone started to depend on networking :)

-- 
	Evgeniy Polyakov
