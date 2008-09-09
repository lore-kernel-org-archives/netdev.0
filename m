From: Jouni Malinen <j@w1.fi>
Subject: Re: [GIT]: Networking
Date: Mon, 8 Sep 2008 22:34:39 -0700
Message-ID: <20080909053439.GA27066@hostap.isc.org>
References: <20080909025525.GB25148@hostap.isc.org> <20080908.204323.04156464.davem@davemloft.net> <20080909040525.GA26151@hostap.isc.org> <20080908.211548.216826057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j@w1.fi, jouni.malinen@atheros.com, alex.williamson@hp.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hostap.isc.org ([149.20.54.63]:59573 "EHLO hostap.isc.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751896AbYIIFnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 01:43:24 -0400
Content-Disposition: inline
In-Reply-To: <20080908.211548.216826057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 09:15:48PM -0700, David Miller wrote:
> From: Jouni Malinen <j@w1.fi>
> > Would people be fine with extending wireless_send_event() with new
> > event types that use fixed sized fields or is someone going to be
> > interesting in providing a better replacement for this
> > functionality?

> I thought this was the idea behind nl80211?  To be a new netlink
> interface for wireless, one that actually is designed correctly
> from the start and thus can avoid all of these problems.

Well, this wireless_send_event() is the part of WEXT that no one has
worked with replacing yet as far as I'm aware.. The currently available
infrastructure in nl80211 can be relatively easily extended to handle
all other functionality, but unless I've missed something, this sending
of event messages to user space would require new type of functionality
for nl8211. In other words, sure, it can be done, but we are not there
yet.

-- 
Jouni Malinen                                            PGP id EFC895FA
