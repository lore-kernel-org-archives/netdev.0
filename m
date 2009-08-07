From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Thu, 06 Aug 2009 20:08:57 -0700 (PDT)
Message-ID: <20090806.200857.172982468.davem@davemloft.net>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
	<20090806.134126.58668200.davem@davemloft.net>
	<OF41857EFE.FD813620-ON6525760B.000F5D7C-6525760B.00101EC7@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755665AbZHGDIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 23:08:48 -0400
In-Reply-To: <OF41857EFE.FD813620-ON6525760B.000F5D7C-6525760B.00101EC7@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Fri, 7 Aug 2009 08:26:04 +0530

> David Miller <davem@davemloft.net> wrote on 08/07/2009 02:11:26 AM:
> 
>> I'm dubious about this new qlen accounting scheme, does it handle
>> the non-bypass case properly?  Can you explain how it works
>> exactly?
> 
> Adding one to qlen will handle non-bypass correctly. On the next
> non-bypass (or a bypass) xmit, dequeue_skb will remove gso_skb and
> decrement the counter. If no more xmits are done, qdisc_reset will
> also fix it. I got this idea by extending one of Jarek's patches:

Aha, I see.  Thanks for the explanation.

Ok, I'll let this rip... let's see what falls out of it :-)
Will apply this to net-next-2.6 right now.
