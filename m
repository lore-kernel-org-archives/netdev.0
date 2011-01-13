From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] etherdevice.h: Add is_unicast_ether_addr
 function
Date: Thu, 13 Jan 2011 00:43:15 -0800
Message-ID: <1294908195.4114.43.camel@Joe-Laptop>
References: <20110112.234250.10542369.davem@davemloft.net>
	 <1294906496-14950-1-git-send-email-tklauser@distanz.ch>
	 <1294907081.4114.35.camel@Joe-Laptop>  <20110113083519.GW29757@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cmetcalf@tilera.com,
	netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3128 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756587Ab1AMInS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 03:43:18 -0500
In-Reply-To: <20110113083519.GW29757@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-13 at 09:35 +0100, Tobias Klauser wrote:
> On 2011-01-13 at 09:24:41 +0100, Joe Perches <joe@perches.com> wrote:
> I added is_unicast_ether_addr to make the intention of checking for a
> unicast address clearer (see [1] for context).
> [1] http://article.gmane.org/gmane.linux.network/183615
> > I can't think of much reason that a new function for
> > !multicast without the !is_zero is needed.
> Maybe I should just add something like the following?
> #define is_unicast_ether_addr(addr) is_valid_ether_addr(addr)

Adding the #define makes a bit more sense to me.


