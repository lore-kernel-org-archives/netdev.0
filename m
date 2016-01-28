From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates [mac80211]
Date: Thu, 28 Jan 2016 14:04:53 -0800
Message-ID: <CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	<1453983185.2217.12.camel@sipsolutions.net>
	<CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	<1454013625.2332.9.camel@sipsolutions.net>
	<CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38904 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbcA1WEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 17:04:54 -0500
In-Reply-To: <CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 1:44 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I will try Johannes' suggestion on that machine to see if it makes a
> difference

Well, it "makes a difference" in the sense that the warning goes away.
But it doesn't make things work. In fact, it might be making things
worse.

Because with that patch, the wireless still authenticates and
associates, but then it doesn't even get an IP address, so now even
dhcp doesn't work. Of course, I was surprised that it worked last
time, and I'm not 100% sure it did work consistently. I'll re-test
without the patch, just to make sure, but it doesn't really seem to
improve on anything.

                Linus
