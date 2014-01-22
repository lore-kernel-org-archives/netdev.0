From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Fix some fallout from the etner_addr_copy()
 changes.
Date: Wed, 22 Jan 2014 14:56:36 -0800
Message-ID: <1390431396.31946.95.camel@joe-AO722>
References: <20140121.190348.1653034020095660800.davem@davemloft.net>
	 <20140121232331.130f34fc.billfink@mindspring.com>
	 <20140121.225431.117378955801559296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0233.hostedemail.com ([216.40.44.233]:48391 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752711AbaAVW4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 17:56:40 -0500
In-Reply-To: <20140121.225431.117378955801559296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-21 at 22:54 -0800, David Miller wrote:
> From: Bill Fink <billfink@mindspring.com>
> Date: Tue, 21 Jan 2014 23:23:31 -0500
> 
> > The commit message indicates problems with appletalk/aarp.c,
> > atm/lec.c, and caif/caif_usb.c, but the diffstat and patch only
> > address the first two and not caif/caif_usb.c.  Is that intended
> > or am I missing something.
> 
> Thanks for catching that, I just pushed the missing change.

My apologies for my stupid carelessness in the
patches I sent here.

I thought #define ETH_ALEN was in the same #include
as ether_addr_copy and I didn't bother compiling.
