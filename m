From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 14:25:24 -0700
Message-ID: <OF2DB62F4D.74FDB455-ON88257379.007520E2-88257379.0075964F@us.ibm.com>
References: <471915FC.1000604@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45453 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965570AbXJSVZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 17:25:35 -0400
In-Reply-To: <471915FC.1000604@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know about a new knob, but it's the same notion
as rp_filter, so why not use rpf for RTN_LOCAL types?
Ie, allow RTN_LOCAL and RTN_UNICAST at the top, but
check rpf if the devs aren't equal or RTN_LOCAL....

It seems like not a good thing to rely on in the first place, though;
usually receiving things from yourself is a bad thing. :-)

                                        +-DLS

