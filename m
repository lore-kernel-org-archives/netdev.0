From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] i386: optimize memset of 6 and 8 bytes
Date: Fri, 17 Aug 2007 18:49:34 -0700
Message-ID: <1187401774.2789.0.camel@laptopd505.fenrus.org>
References: <20070817165030.5455f761@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58259 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbXHRBxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:53:42 -0400
In-Reply-To: <20070817165030.5455f761@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-08-17 at 16:50 -0700, Stephen Hemminger wrote:
> Tne network code does memset for 6 and 8 byte values, that can easily
> be optimized into simple assignments without string instructions.


so... question.
Why are we doing this by hand? Wouldn't gcc just generate this code in
the first place (when using __builtin_memset)? I very much suspect it
would (and if some version doesn't.... we really ought to get that
fixed)

