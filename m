From: David Miller <davem@davemloft.net>
Subject: Re: TX time stamping
Date: Thu, 19 Mar 2009 14:05:09 -0700 (PDT)
Message-ID: <20090319.140509.152824531.davem@davemloft.net>
References: <1236105081.4653.68.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752454AbZCSVFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 17:05:22 -0400
In-Reply-To: <1236105081.4653.68.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You still haven't done anything to address this fundamental issue with
your timestamping changes.  I've been more than patient enough.

It is also not anyone's obligation to help you fix this problem.
You want to add this new feature, whereas I do not consider it
essential in any way whatsoever.

So I am going to have to revert this work, since it appears that being
able to get at skb->sk after the transmit function runs was an
essential requirement to how your code works.

And that will simply never ever work.

This is why I tried to wait a long time to integrate these patches in
the first place, I'd had hoped that you had worked out all of these
kinds of issues during that time.

Instead, we have a half-working turd in a tree, and I'm removing it.
