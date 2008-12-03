From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/3 v2] pkt_sched: sch_htb: Clean L2T()
Date: Wed, 03 Dec 2008 00:20:46 -0800 (PST)
Message-ID: <20081203.002046.153795689.davem@davemloft.net>
References: <20081203070947.GA5598@ff.dom.local>
	<20081202.232522.108544572.davem@davemloft.net>
	<20081203075433.GA7137@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751259AbYLCIUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 03:20:46 -0500
In-Reply-To: <20081203075433.GA7137@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 3 Dec 2008 07:54:33 +0000

> On Tue, Dec 02, 2008 at 11:25:22PM -0800, David Miller wrote:
> ...
> > Jarek, please just kill the macro and expand the calculation inline.
> 
> Hmm.. no problem... unless you think about the other macro?

You misunderstood me.

I meant get rid of L2T completely, and just use
"qdisc_l2t(rate, size)" directly.

Macros like this one:

1) are used in only one spot
2) give no new information to the reader

so are just extra noise.
