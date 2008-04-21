From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: Re: [RFC 0/4] net: enable timestamps on a per-socket basis
Date: Mon, 21 Apr 2008 00:28:45 -0700
Message-ID: <20080421072845.GC23476@48M1231.sanmateo.corp.akamai.com>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com> <20080420.230356.238029889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay03.akamai.com ([72.247.150.167]:58536 "EHLO
	prod-mail-xrelay03.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbYDUH2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 03:28:46 -0400
Content-Disposition: inline
In-Reply-To: <20080420.230356.238029889.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 20, 2008 at 23:03:56 -0700, David Miller wrote:
> Moving the timestamp up to a higher level takes away some of the
> frequent use cases of timestamps, which is to detect things like the
> fact that it is taking a long time for packets to get from the
> top-level packet receive down to the actual protocol processing.
> 
> With your patch, it can't be used that way any more.
> 
> In fact, people are desiring timestamps which are _closer_ to when the
> device actually receives the frame rather than further away.

Fair enough.

It's too bad that SO_TIMESTAMP has a scope of impact which really has
nothing to do with a socket, though.  It almost seems like it should
have been an interface flag instead of a socket option.
