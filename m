From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some	time
Date: Mon, 1 Sep 2008 06:03:31 -0700
Message-ID: <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com>
References: <20080831182034.GA12035@pest>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40121 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbYIANDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 09:03:35 -0400
In-Reply-To: <20080831182034.GA12035@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, it'd certainly be good to identify exactly where in
the sendmsg path you're getting the EINVAL from. If
possible, I'd suggest putting in some debugging code
and reproducing it.

 If you can pick up the exact arguments when it's happening
via strace and send those here, that may help, but I wouldn't
expect those to be incorrect from ping6 only some of the
time...

I'll look into this some more if someone doesn't beat me to
it, but I'm travelling now so it will be a few days at least before
I get to it.

                                        +-DLS

