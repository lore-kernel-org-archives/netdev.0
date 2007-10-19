From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 10:43:01 -0700
Message-ID: <OF743FE77C.521201D4-ON88257379.00608213-88257379.00613A32@us.ibm.com>
References: <4718E02E.1080603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: brian.haley@hp.com, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49531 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935836AbXJSRnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 13:43:11 -0400
In-Reply-To: <4718E02E.1080603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know why you'd want it to be different for multicasting. If you
want to hear your own multicasts, you should use MULTICAST_LOOP;
hearing them off the wire indicates all the same bad things -- a forger,
a duplicate address or a routing loop. Those aren't any better for
multicasting than they are for unicasting, that I can see.

Why would you want that to be delivered, other than (apparently)
to test the multicast capability of a pair of interfaces while using
only 1 machine?

                                        +-DLS


