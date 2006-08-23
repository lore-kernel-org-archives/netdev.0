From: David Miller <davem@davemloft.net>
Subject: Re: ProxyARP and IPSec
Date: Wed, 23 Aug 2006 15:14:24 -0700 (PDT)
Message-ID: <20060823.151424.78711856.davem@davemloft.net>
References: <44EBA1FC.5000801@zytor.com>
	<20060823191425.GK3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10185
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965236AbWHWWOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 18:14:23 -0400
To: tgraf@suug.ch
In-Reply-To: <20060823191425.GK3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 23 Aug 2006 21:14:25 +0200

> * H. Peter Anvin <hpa@zytor.com> 2006-08-22 17:31
> > Specifically, Linux will not ProxyARP for an address unless it has a 
> > route for it, *and* that route either has a DNAT marking or points to a 
> > different interface than the input interface:
> 
> I can think of a very ugly way: Use netfilter to match on the
> arp packet prerouting, set nfmark to some value, create a routing
> rule matching the fwmark again, have it look up a separate table
> with a dummy route pointing to a dummy device. Make sure to have
> a proxy neighbour entry as using the device proxy_arp sysctl would
> fail again.

This shows we have a usability problem if that's the only way
to do this :-)

What he's trying to accomplish doesn't sound all that weird,
does anyone have any other ideas?
