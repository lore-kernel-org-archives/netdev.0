From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 5/5] alx: add stats to ethtool
Date: Mon, 06 Jan 2014 16:16:31 +0100
Message-ID: <1389021391.5891.26.camel@jlt4.sipsolutions.net>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
	 <1388854031-24142-6-git-send-email-sd@queasysnail.net>
	 <1388998990.5891.0.camel@jlt4.sipsolutions.net>
	 <20140106105742.GA30142@kria>
	 <1389017496.5891.15.camel@jlt4.sipsolutions.net>
	 <20140106145629.GA7886@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:43063 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165AbaAFPQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 10:16:37 -0500
In-Reply-To: <20140106145629.GA7886@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 15:56 +0100, Sabrina Dubroca wrote:

> > I was more worried about type mismatches. That's not really a concern
> > with u64 since that's the largest type that really makes sense here, but
> > if the type of some variables changed vs. the ethtool type u64...
> 
> Add "all stats fields must be u64" to the comment before the struct?

I guess that's OK. I can live with either of these solutions really, I
have no plans to change this driver ever again (though I might need WOL
soon ... *sigh*)

johannes
