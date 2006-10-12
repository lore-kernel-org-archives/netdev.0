From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Thu, 12 Oct 2006 08:10:43 +0200
Message-ID: <452DDC63.2030707@trash.net>
References: <200610111511.19028.dada1@cosmosbay.com>	<20061011.220506.76273501.davem@davemloft.net>	<452DD724.4030502@cosmosbay.com> <20061011.230233.122062793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11998 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1161245AbWJLGJR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 02:09:17 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061011.230233.122062793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Indeed, numbers talk bullshit walks :)

:)

> How about something like this as a start?
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c

The same problem is also present in dn_route.c (3 uninitialized
bytes in dn_u).

