From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] FIB_HASH : Avoid unecessary loop in fn_hash_dump_zone()
Date: Fri, 18 Jan 2008 04:30:45 -0800 (PST)
Message-ID: <20080118.043045.23272694.davem@davemloft.net>
References: <20080116181925.2c5c540f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54337
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755750AbYARMao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 07:30:44 -0500
In-Reply-To: <20080116181925.2c5c540f.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 16 Jan 2008 18:19:25 +0100

> I noticed "ip route list" was slower than "cat /proc/net/route" on a machine with a full Internet
> routing table (214392 entries : Special thanks to Robert ;) )
> 
> This is similar to problem reported in commit d8c9283089287341c85a0a69de32c2287a990e71
> 
> Fix is to avoid scanning the begining of fz_hash table, but directly seek to the right offset.
> 
> Before patch :
> 
> time ip route >/tmp/ROUTE
> 
> real    0m1.285s
> user    0m0.712s
> sys     0m0.436s
> 
> After patch
> 
> # time ip route >/tmp/ROUTE
> 
> real    0m0.835s
> user    0m0.692s
> sys     0m0.124s
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
