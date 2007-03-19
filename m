From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20.3-rc1 / iproute2 hoplimit 2^32-1 vs 2^8-1
Date: Mon, 19 Mar 2007 12:18:44 -0700 (PDT)
Message-ID: <20070319.121844.112623702.davem@davemloft.net>
References: <Pine.LNX.4.64.0703191706530.3331@netcore.fi>
	<45FEAA3E.20601@trash.net>
	<45FEABE1.9050003@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752336AbXCSTSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 15:18:44 -0400
In-Reply-To: <45FEABE1.9050003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 19 Mar 2007 16:27:29 +0100

> Mhh actually this looks intentional:
> 
> icmpv6_send and some other output functions do:
> 	int hlimit;
> ...
>         if (hlimit < 0)
>                 hlimit = dst_metric(dst, RTAX_HOPLIMIT);
>         if (hlimit < 0)
>                 hlimit = ipv6_get_hoplimit(dst->dev);

Yep, negative value has a specific meaning.

