From: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Subject: Re: [take15 4/4] kevent: Timer notifications.
Date: Tue, 5 Sep 2006 15:39:57 +0200
Message-ID: <200609051539.58492.arnd.bergmann@de.ibm.com>
References: <11573648632380@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:29870 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965036AbWIENkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 09:40:02 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11573648632380@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 04 September 2006 12:14, Evgeniy Polyakov wrote:
> Timer notifications can be used for fine grained per-process time 
> management, since interval timers are very inconvenient to use, 
> and they are limited.

I guess this must have been discussed before, but why is this
not using high-resolution timers?

Are you planning to change this?

Maybe at least mention it in the description.

	Arnd <><
