From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Fri, 25 Jul 2008 02:26:38 +0300
Message-ID: <200807250226.38996.opurdila@ixiacom.com>
References: <200807250112.03379.opurdila@ixiacom.com> <200807250214.11298.opurdila@ixiacom.com> <20080724.161859.193696763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3799 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756400AbYGXX3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 19:29:07 -0400
In-Reply-To: <20080724.161859.193696763.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 July 2008, David Miller wrote:

> > Sure but the problem is that the NIC hw timestamp is not synced with
> > the CPU time. In that case I think that the netfilter rules which
> > are looking at the timestamp will be messed up.
>
> Right, but you can maintain a suitable "delta" between the two.

OK, I think I got the idea now:
- use a bit in the timestamp to specify that this is a hw timestamp
- use a new net_device method to convert a hw timestamp to a gettimeofday 
timestamp

This is great, thanks a lot !

tavi
