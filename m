From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: linux-next: build failure after merge of the staging tree
Date: Wed, 03 Jun 2015 09:23:13 +0200
Message-ID: <1433316193.2274.5.camel@sipsolutions.net>
References: <20150603171634.2da4f45d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Johnny Kim <johnny.kim@atmel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43004 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645AbbFCHXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 03:23:22 -0400
In-Reply-To: <20150603171634.2da4f45d@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, all,

> Caused by commit c5c77ba18ea6 ("staging: wilc1000: Add SDIO/SPI 802.11
> driver") from the staging tree interacting with commit 80279fb7ba5b
> ("cfg80211: properly send NL80211_ATTR_DISCONNECTED_BY_AP in
> disconnect") from the net-next tree.

I thought I fixed it all, but it looks like this is a new driver.

> I applied the below merge fix patch (I didn't know if it should be
> "true" or "false" - advise would be nice).

As far as I can tell from looking at a few lines of context it's
handling a disconnect event from the firmware, which presumably sends
the event upon deauth from the AP; thus it should be 'true' instead,
since the argument says "from_ap".

johannes
