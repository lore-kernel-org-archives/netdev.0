From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Sun, 29 Aug 2010 21:23:11 -0700 (PDT)
Message-ID: <20100829.212311.35029746.davem@davemloft.net>
References: <20100830130453.d810b086.sfr@canb.auug.org.au>
	<20100830032935.GA18072@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59013
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751070Ab0H3EWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 00:22:55 -0400
In-Reply-To: <20100830032935.GA18072@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 30 Aug 2010 12:29:39 +0900

> On Mon, Aug 30, 2010 at 01:04:53PM +1000, Stephen Rothwell wrote:
>> Hi all,
>> 
>> After merging the final tree, today's linux-next build (powerpc
>> allyesconfig) failed like this:
>> 
>> net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_nat_icmp_v6':
>> net/netfilter/ipvs/ip_vs_core.c:640: error: implicit declaration of function 'csum_ipv6_magic'
>> 
>> Caused by commit 8870f8427b8fe30b2684b9e569e5ce038faf41ac ("IPVS: ICMPv6
>> checksum calculation").  I added the following patch:
>> [I think we have seen this before :-(]
>> 
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Mon, 30 Aug 2010 13:01:20 +1000
>> Subject: [PATCH] IPVS: include net/ip6_checksum.h for csum_ipv6_magic
>> 
>> Fixes this build error:
>> 
>> net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_nat_icmp_v6':
>> net/netfilter/ipvs/ip_vs_core.c:640: error: implicit declaration of function 'csum_ipv6_magic'
> 
> Sorry about that, I didn't notice it because it doesn't show up on x86.
> 
>> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied thanks everyone.
