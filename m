From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 18:59:31 +0100
Message-ID: <45746203.2030400@trash.net>
References: <1165158707.3517.92.camel@localhost>	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>	 <1165240725.3664.72.camel@localhost>  <1165241100.3664.75.camel@localhost>	 <1165246635.3643.6.camel@localhost>  <457444E0.8060801@trash.net> <1165254213.3643.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50254 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068AbWLDR4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 12:56:23 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165254213.3643.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Ok, both looked good except for the test of a single entry.
> This was because you would break out of the loop with count of 0.
> The patch against yours would look like something attached for the state
> case. Dont forget there are two spots on the policy side of things;->

You're right, that case was also broken. With your patch on top
it looks all right.

> You can either submit both patches or i could later today. If you do,
> please look at some of the comments i made in the first patch and
> include them. 

I'd prefer if you did it since you're already testing the thing :)
