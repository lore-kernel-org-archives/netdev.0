From: Matthias Andree <matthias.andree@gmx.de>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Tue, 19 May 2009 11:05:17 +0200
Message-ID: <4A12764D.4010600@gmx.de>
References: <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>	<20090517.154137.104422195.davem@davemloft.net>	<Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi> <20090518.150433.92463181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, elendil@planet.nl,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:35247 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752495AbZESJFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 05:05:18 -0400
In-Reply-To: <20090518.150433.92463181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller schrieb:

> Since I now understand your urg_hole code I'm going to apply your v2
> patch which takes care of the URG stuff.  I also buy the argument that
> perhaps we should get rid of the log message, but look at how it
> helped us find this kernel regression :-)

Hi,

...and this discovery is a reason to leave it in, and perhaps make sure
that the check code is properly linked (through comments for lack of better
means) to the actual data transfer functions.

Cheers
MA
