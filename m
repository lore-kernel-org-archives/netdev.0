From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Wed, 13 Apr 2011 10:43:17 -0700 (PDT)
Message-ID: <20110413.104317.71110417.davem@davemloft.net>
References: <1302663327.2811.55.camel@edumazet-laptop>
	<1302663608.2811.62.camel@edumazet-laptop>
	<BANLkTi=1wmQYRgHmO5SbPBiSwzKwVz4_ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42841
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751511Ab1DMRnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 13:43:52 -0400
In-Reply-To: <BANLkTi=1wmQYRgHmO5SbPBiSwzKwVz4_ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <dbaluta@ixiacom.com>
Date: Wed, 13 Apr 2011 14:57:18 +0300

> Cyril's use case looks suspect. I don't think that this is a good
> reason for reverting this commit.

I complete disagree.

Something that worked perfectly fine, probably for years, we broke.

We simply cannot do that, especially since we do not have a reasonable
alternative at this time.

Adding SO_REUSEPORT is a long range option, and not something that
will provide a fix for users right now.

So please don't even pretend to suggest that we shouldn't fix this
with a revert unless a simple, obvious, kernel fix presents itself.
