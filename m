From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 12:24:42 -0500
Message-ID: <1289582682.3090.323.camel@Dan>
References: <2129857903-1289528127-cardhu_decombobulator_blackberry.rim.net-1506931048-@bda083.bisx.prod.on.blackberry>
	 <20101111.182939.258124014.davem@davemloft.net>
	 <1289529269.3090.207.camel@Dan>
	 <1289546610.17691.1770.camel@edumazet-laptop>
	 <20101112083315.096dfaa3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:49976 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab0KLRYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 12:24:47 -0500
In-Reply-To: <20101112083315.096dfaa3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Also, the whole idea needs to be under a config option, so only
> the paranoid idiots turn it on.

If that's what's necessary to get it accepted, I'm willing to do that.
But when a solution does not negatively impact usability or performance
and improves security, even in a small way, why should it not be enabled
by default?  Of course it's my responsibility to first propose a
solution that is acceptable from a usability/debugging standpoint, but
assuming that can be achieved, I don't really see what the problem is.
There's a difference between being a "paranoid idiot" and wanting to
protect users from unnecessary exposure.

-Dan

