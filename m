From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:10:38 -0700 (PDT)
Message-ID: <20101026.101038.260090183.davem@davemloft.net>
References: <20101025213841.635b9a15@nehalam>
	<AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
	<4CC708CE.4040404@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932308Ab0JZRKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:10:15 -0400
In-Reply-To: <4CC708CE.4040404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 26 Oct 2010 12:58:54 -0400

> Having these addresses restart DAD is probably about as much as we
> can do I think, unless we add a per-device sysctl to remove the addresses
> (which I think has been shot-down before).

It would be fundamentally flawed, in my opinion, if the normal
mechanisms of ipv6 cannot handle this situation adequately.

That's really why I don't even want to consider the "blow away
the addresses" sysctl option.

