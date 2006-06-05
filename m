From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hush noisy ieee80211 CCMP printks
Date: Mon, 5 Jun 2006 06:31:48 -0700
Message-ID: <20060605133147.GA9567@jm.kir.nu>
References: <20060605001208.GA4585@opus.vpn-dev.reflex>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:53483 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP
	id S1751107AbWFENcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 09:32:31 -0400
To: Jason Lunz <lunz@falooley.org>
Content-Disposition: inline
In-Reply-To: <20060605001208.GA4585@opus.vpn-dev.reflex>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 04, 2006 at 08:12:09PM -0400, Jason Lunz wrote:

> Don't swamp syslog with
> CCMP: decrypt failed: STA=00:12:17:3a:e2:c7
> and 
> CCMP: replay detected: STA=00:12:17:3a:e2:c7 previous PN 000000000004 received PN 000000000004
> messages.
> 
> These both seem to be completely normal in regular use, especially
> 'decrypt failed' whenever another wpa-using station on the same AP is
> within range.

These are not normal, i.e., they should not really show up unless
something goes wrong. In many cases, this may be caused by something
missing in local filtering (e.g., retry duplicates are not filtered out
correctly or messages to incorrect addresses are allowed through, etc.).
In other cases, it can indicate incorrect implementation of rekeying or
some other bugs in either end of the connection. Anyway, I don't have
anything against removing the messages in default kernel builds. If
there is a suitable build time debug option, that might be nicer way of
doing this, though, since these can provide valuable information when
figuring out why something does not work.

-- 
Jouni Malinen                                            PGP id EFC895FA
