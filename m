From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]IPv6: Delete redundant counter of IPSTATS_MIB_REASMFAILS
Date: Mon, 15 Feb 2010 21:54:20 -0800 (PST)
Message-ID: <20100215.215420.223373630.davem@davemloft.net>
References: <4B73D81D.1000601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	adobriyan@gmail.com, opurdila@ixiacom.com, yanghy@cn.fujitsu.com,
	netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41373
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159Ab0BPFyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:54:05 -0500
In-Reply-To: <4B73D81D.1000601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 11 Feb 2010 18:12:45 +0800

> 
> When no more memory can be allocated, fq_find() will return NULL and 
> increase the value of IPSTATS_MIB_REASMFAILS. In this case,
> ipv6_frag_rcv() also increase the value of IPSTATS_MIB_REASMFAILS.
> 
> So, the patch deletes redundant counter of IPSTATS_MIB_REASMFAILS in fq_find().
> and deletes the unused parameter of idev.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied to net-next-2.6, thanks.
