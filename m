From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] IPv4/IPv6: update sysctl files
Date: Wed, 08 Apr 2009 03:47:43 +0100
Message-ID: <1239158863.11534.52.camel@deadeye.i.decadent.org.uk>
References: <49DC091C.6070708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shen Feng <shen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47071 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751780AbZDHCrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 22:47:53 -0400
In-Reply-To: <49DC091C.6070708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-08 at 02:39 +0000, Shen Feng wrote:
> Now the following sysctl files in /proc/sys/net/ipv4 are used by
> both IPv4 and IPv6.
> tcp_mem  tcp_rmem  tcp_wmem
> udp_mem  udp_rmem_min  udp_wmem_min
> Putting them in /proc/sys/net/ipv4 is not a good choice.
[...]

But this is part of the ABI to userland.  You cannot remove sysctl files
without long advance notice documented in feature-removal-schedule.txt
(if at all).

If it is possible to add the paths
/proc/sys/net/{tcp,udp} while retaining aliases under /proc/sys/net/ipv4
then that might be a workable solution.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
