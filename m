From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Speed-up pfifo_fast lookup using a private bitmap
Date: Sat, 29 Aug 2009 00:19:41 -0700 (PDT)
Message-ID: <20090829.001941.38682647.davem@davemloft.net>
References: <20090819075559.734.17523.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kaber@trash.net
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750770AbZH2HT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:19:28 -0400
In-Reply-To: <20090819075559.734.17523.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 19 Aug 2009 13:25:59 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Maintain a per-qdisc bitmap for pfifo_fast giving  availability
> of skbs for each band. This allows faster lookup for a skb when
> there are no high priority skbs. Also, it helps in (rare) cases
> when there are no skbs on the list, where an immediate lookup is
> faster than iterating through the three bands.
> 
> Changelog v1 -> v2
> 
> 1. Moved the bitmap from Qdisc to the private area of pfifo_fast
> 2. pfifo_fast_reset sets bitmap to zero
> 3. Undo a line-wrap in initializing a variable
> 4. Fixed some comments
> 5. Readability and checkpatch fixes
> 
> Thanks,
> 
> - KK
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied, thanks.
