From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 5 Dec 2007 16:33:38 -0500
Message-ID: <20071205163338.50aff45d@shemminger-laptop>
References: <20071205.053031.87154402.davem@davemloft.net>
	<1196873587.10819.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59555 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751913AbXLEVer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 16:34:47 -0500
In-Reply-To: <1196873587.10819.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Dec 2007 08:53:07 -0800
Joe Perches <joe@perches.com> wrote:

> > it occurred to me that we might want to do something
> > like a state change event generator.
> 
> This could be a basis for an interesting TCP
> performance tester.

That is what tcpprobe does but it isn't detailed enough to address SACK
issues.
