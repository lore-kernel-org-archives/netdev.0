From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 10:33:10 -0800
Message-ID: <20101112103310.5504cf77@nehalam>
References: <2129857903-1289528127-cardhu_decombobulator_blackberry.rim.net-1506931048-@bda083.bisx.prod.on.blackberry>
	<20101111.182939.258124014.davem@davemloft.net>
	<1289529269.3090.207.camel@Dan>
	<1289546610.17691.1770.camel@edumazet-laptop>
	<20101112083315.096dfaa3@nehalam>
	<1289582682.3090.323.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	kuznet@ms2.inr.ac.ru, urs.thuermann@volkswagen.de,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jmorris@namei.org,
	remi.denis-courmont@nokia.com, pekkas@netcore.fi, sri@us.ibm.com,
	vladislav.yasevich@hp.com, tj@kernel.org, lizf@cn.fujitsu.com,
	joe@perches.com, hadi@mojatatu.com, ebiederm@xmission.com,
	adobriyan@gmail.com, jpirko@redhat.com, johannes.berg@intel.com,
	daniel.lezcano@free.fr, xemul@openvz.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, torvalds@linux-foundation.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57517 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829Ab0KLSdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Nov 2010 13:33:18 -0500
In-Reply-To: <1289582682.3090.323.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Nov 2010 12:24:42 -0500
Dan Rosenberg <drosenberg@vsecurity.com> wrote:

> 
> > 
> > Also, the whole idea needs to be under a config option, so only
> > the paranoid idiots turn it on.
> 
> If that's what's necessary to get it accepted, I'm willing to do that.
> But when a solution does not negatively impact usability or performance
> and improves security, even in a small way, why should it not be enabled
> by default?  Of course it's my responsibility to first propose a
> solution that is acceptable from a usability/debugging standpoint, but
> assuming that can be achieved, I don't really see what the problem is.
> There's a difference between being a "paranoid idiot" and wanting to
> protect users from unnecessary exposure.

See earlier discussion about automatically running crypto tests on boot
which caused Linus to flame. This is more intrusive, and is not something
most developers would want; but it might make sense in production
environment.

