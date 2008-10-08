From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next 10/14] ipv6: ICMP6MSGIN_INC_STATS is not used
Date: Wed, 8 Oct 2008 10:37:25 -0700
Message-ID: <OFA8E1BB63.D89C2A10-ON882574DC.00607E02-882574DC.0060CF64@us.ibm.com>
References: <1223466722-8169-10-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: benjamin.thery@bull.net, davem@davemloft.net,
	"Denis V. Lunev" <den@openvz.org>, dlezcano@fr.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	xemul@openvz.org, yoshfuji@linux-ipv6.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45553 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571AbYJHRhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 13:37:42 -0400
In-Reply-To: <1223466722-8169-10-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is there to parallel the definitions for other stats
macros. I don't think it should be removed, since it's
part of the standard interface for incrementing counters.
If someone has a need to increment it without, say, _BH,
I wouldn't want them to have to come up with it from
scratch again...

It's cost is the two lines of code it takes, but you could
consider it "documentation" for any future users that
want that variant.

                                        +-DLS

