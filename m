From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] UDP: Make use of inet_iif() when doing socket lookups.
Date: Thu, 25 Oct 2007 14:58:29 -0700
Message-ID: <OFD4C47A22.AA67398C-ON8825737F.0077CEF6-8825737F.00789CCE@us.ibm.com>
References: <471E403A.7040705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:52572 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758254AbXJYV6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 17:58:32 -0400
In-Reply-To: <471E403A.7040705@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't see any problem with this. If you're using IP_MULTICAST_IF with
a bound socket, it forces you to use that interface, anyway.

I'm not sure multicasting works as expected in some other cases with
bound sockets (looks like there may be some holes to evade the
binding), but that's in old code. I don't see any problems from this
patch.

                                        +-DLS

Acked-by: David L Stevens <dlstevens@us.ibm.com>

