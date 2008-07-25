From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
 length for qdiscs
Date: Fri, 25 Jul 2008 04:49:28 -0700 (PDT)
Message-ID: <20080725.044928.261427957.davem@davemloft.net>
References: <20080725105748.GB10399@ff.dom.local>
	<20080725.035712.33516738.davem@davemloft.net>
	<20080725113757.GC10399@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38009
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752414AbYGYLt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 07:49:29 -0400
In-Reply-To: <20080725113757.GC10399@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 25 Jul 2008 11:37:57 +0000

> On Fri, Jul 25, 2008 at 03:57:12AM -0700, David Miller wrote:
> > Even TCP depends upon that NET_XMIT_* return value having some real
> > meaning, remember the HTB bug we tracked down last week? :-)
> 
> Do you mean this bug you've forgotten to fix yet?

I have not forgotten, it is in TODO list. :)

I want to also inquire with Patrick about whether he is going to
perform the audit in this area which he said he wanted to do :-)

Well, we have patch which fixes the problem for the tester, so we
could just merge that and at least have HTB fixed.  But we know there
are other instances of the same return value propagation problem and
Patrick's audit is sure to turn up other similar turds...
