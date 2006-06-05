From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH] hush noisy ieee80211 CCMP printks
Date: Mon, 5 Jun 2006 12:03:35 -0400
Message-ID: <20060605160335.GB25688@knob.reflex>
References: <20060605001208.GA4585@opus.vpn-dev.reflex> <20060605133147.GA9567@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.reflexsecurity.com ([72.54.64.74]:13250 "EHLO
	crown.reflexsecurity.com") by vger.kernel.org with ESMTP
	id S1751200AbWFEQDj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 12:03:39 -0400
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20060605133147.GA9567@jm.kir.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 06:31:48AM -0700, Jouni Malinen wrote:
> These are not normal, i.e., they should not really show up unless
> something goes wrong.

If these are a real problem, I'll gladly help debug it. I'm using
2.6.17-rc5's bcm43xx and the in-kernel ieee80211 softmac stack. I'm
using wpa/ccmp/aes with an openwrt AP.

> In many cases, this may be caused by something missing in local
> filtering (e.g., retry duplicates are not filtered out correctly or
> messages to incorrect addresses are allowed through, etc.).

Is it the driver's responsibility to do this filtering, or the softmac
stack's? Can you show me a code example where this filtering is done
properly?

> In other cases, it can indicate incorrect implementation of rekeying or
> some other bugs in either end of the connection.

I can try different implementations of WPA in the AP if necessary. I
think openwrt has other options. My end is in-kernel ieee80211_softmac -
is there anything you'd like me to look at there?

> Anyway, I don't have anything against removing the messages in default
> kernel builds. If there is a suitable build time debug option, that
> might be nicer way of doing this, though, since these can provide
> valuable information when figuring out why something does not work.

If the messages are actually useful, and unusual, then they should
probably stay. But I get a LOT of them, and my wireless is working just
fine.

I noticed that there are counters being incremented where those printks
are. How do I see those counters from userspace?

Jason
