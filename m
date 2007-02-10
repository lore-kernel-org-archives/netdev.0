From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] NET Improve layering of structs
 dst_entry/rtable/rt6_info/dn_route to get less dcache footprint
Date: Fri, 09 Feb 2007 17:31:24 -0800 (PST)
Message-ID: <20070209.173124.78709988.davem@davemloft.net>
References: <20070208093935.90CA.SHINTA@sfc.wide.ad.jp>
	<20070207.165213.98418769.davem@davemloft.net>
	<45CB96DA.20400@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbXBJBb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 20:31:26 -0500
In-Reply-To: <45CB96DA.20400@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 08 Feb 2007 22:32:10 +0100

> I prepared the following five patches :
> 
> [PATCH 1/5] : Introduce union in struct dst_entry, to prepare patches 2,3,4
> [PATCH 2/5] : Convert ipv4 route to use the new dst_entry 'next' pointer
> [PATCH 3/5] : Convert ipv6 route to use the new dst_entry 'next' pointer
> [PATCH 4/5] : Convert decnet route to use the new dst_entry 'next' pointer
> [PATCH 5/5] : Reorder fields of struct dst_entry

I've applied all of this, and fixed up the changelog description
of patch #4 as-needed :-)

Thanks a lot Eric.
