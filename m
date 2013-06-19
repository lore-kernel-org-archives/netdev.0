From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] nl80211: fix attrbuf access race by allocating a separate one
Date: Wed, 19 Jun 2013 06:26:49 -1000
Message-ID: <CA+55aFx239=D_ZiKUPD0x9a+L2HQC9LSzG6aH2=dPd8=sLSXVg@mail.gmail.com>
References: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>
	<20130618.190632.33329016434510583.davem@davemloft.net>
	<CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
	<1371628488.8349.3.camel@jlt4.sipsolutions.net>
	<1371630238.8349.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:51876 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049Ab3FSQ0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 12:26:50 -0400
In-Reply-To: <1371630238.8349.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 18, 2013 at 10:23 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
> Let me know if you want to apply this directly, otherwise I'll send it
> on its way to John.

The problem doesn't happen often enough to make this an acute issue
for me, so this patch might as well go through the normal channels.

Thanks,

          Linus
