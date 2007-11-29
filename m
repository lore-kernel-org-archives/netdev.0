From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Thu, 29 Nov 2007 23:03:05 +0100
Message-ID: <474F3719.30101@trash.net>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57804 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbXK2WDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 17:03:37 -0500
In-Reply-To: <20071129134554.5c25a891@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Still interested in this. I got part way through integrating it but had
> concerns about the API from the application to netem for getting the data.
> It seemed like there ought to be a better way to do it that could handle large
> data sets better, but never really got a good solution worked out (that is why
> I never said anything).

Would spreading them over multiple netlink messages work? A different,
slightly ugly possibility would be to simply use copy_from_user, netlink
is synchronous now (still better than using configfs IMO).


