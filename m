From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][IPSEC][4/6] changing "ipip tunnel" and xfrm4_tunnel to
 the API change
Date: Fri, 09 Feb 2007 09:36:56 +0100
Message-ID: <45CC32A8.5070800@trash.net>
References: <20070208170412.2e627947.kazunori@miyazawa.org> <45CB2148.8060307@trash.net> <45CBC24D.9040408@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, Miika Komu <miika@iki.fi>,
	Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60845 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946207AbXBIIg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 03:36:59 -0500
In-Reply-To: <45CBC24D.9040408@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kazunori MIYAZAWA wrote:
> Thank you Patrick for your review.
> I'll fix and send again.

Thanks.

> BTW, I'm going to use separete xfrm_tunnel_handler to solve
> the issue which you pointed at the moment. But why does
> "register twice" corrupt the list even if I use separate lists
> for the address family.

The next pointer in xfrm_tunnel_handler will get overwritten on
the second registration.

