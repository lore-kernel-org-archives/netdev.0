From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Wed, 05 May 2010 15:00:08 -0700 (PDT)
Message-ID: <20100505.150008.102542618.davem@davemloft.net>
References: <4BE031FA.6040006@hp.com>
	<20100504.144647.157477097.davem@davemloft.net>
	<4BE1907F.40903@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753293Ab0EEWAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 18:00:02 -0400
In-Reply-To: <4BE1907F.40903@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 05 May 2010 11:36:31 -0400

> I now see that in Elliot's email, but I think it's incorrect.  The RFC
> says that setting it to -1 should get you the kernel default, which is
> now 1.  Without this change, setting it to -1 will get you 64, the
> old behavior.  If the user wants to, they can always just set it to
> 64 themselves, that's better than assuming when you set it to -1
> you're going to get 64.

It's not 64, it's whatever the per-route metric is.

> I'm just trying to make this follow the RFC and behave like other OSes
> for consistency.

I'm just trying to have a real compatability story, and we don't with
any of the proposals you guys are giving me because it complete ignores
the fact that the old default comes from the route and is not some
constant.
