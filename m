From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Wed, 19 Dec 2007 11:28:48 -0800
Message-ID: <OF5E6AD5B5.F8D668D5-ON882573B6.006AAA3D-882573B6.006B2FE2@us.ibm.com>
References: <47696DCF.3000009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44481 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbXLSTbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 14:31:02 -0500
In-Reply-To: <47696DCF.3000009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> We would still have to check np->mcast_oif is set in the link-local case 

> since we shouldn't be getting here with a zero.

        Actually, that's one of the things I wanted to look into. I'm not
sure if there's a path through here with (even non-linklocal) multicasts
that end up without an interface set. And I'd to do some testing of
different cases to see if they behave as expected; also compare to the
similar sendmsg() cases.

> 
> Don't worry about that, they can wait, and I'm leaving for 10 days 
> anyways...

        Good, thanks. It has been this way for years now, and I'm out
too. :-) Enjoy,

                                                                +-DLS

