From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 04 May 2010 14:46:47 -0700 (PDT)
Message-ID: <20100504.144647.157477097.davem@davemloft.net>
References: <OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com>
	<20100504.005757.97355845.davem@davemloft.net>
	<4BE031FA.6040006@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753520Ab0EDVqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 17:46:40 -0400
In-Reply-To: <4BE031FA.6040006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 04 May 2010 10:40:58 -0400

> Specifying -1 for setsockopt(IPV6_MULTICAST_HOPS) should set the socket
> value back to the system default value of IPV6_DEFAULT_MCASTHOPS (1).
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

In cast it wasn't clear from my other reply, I'm not applying this
patch because I intentionally left this behavior there based upon
some comments from Elliot in that this lets developers get the
old default by asking for "-1" explicitly with a setsockopt.
