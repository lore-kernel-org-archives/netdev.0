From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Provide SYN packet for passive connections
Date: Sun, 11 Mar 2012 21:14:24 -0700 (PDT)
Message-ID: <20120311.211424.996831768685832926.davem@davemloft.net>
References: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
	<20120311.195542.1995263719633128071.davem@davemloft.net>
	<CA+mtBx_LqwUpe5Df3VPw-L=h-WUjr=fxh86rgNuYnMacNikuOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab2CLEOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 00:14:43 -0400
In-Reply-To: <CA+mtBx_LqwUpe5Df3VPw-L=h-WUjr=fxh86rgNuYnMacNikuOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 11 Mar 2012 21:08:38 -0700

> For inet_connection_sock I believe there are fields that would only be
> used for a listeners(e.g. icsk_accept_queue), and fields that would
> only be used for a real connection (e.g. icsk_retransmits).  Would it
> be worth it to split these into a union?

Indeed, it might.
