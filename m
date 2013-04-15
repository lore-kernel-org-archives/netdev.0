From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [Patch net-next] ipv6: statically link
 register_inet6addr_notifier()
Date: Mon, 15 Apr 2013 13:12:35 +0200
Message-ID: <1366024355.8361.13.camel@jlt4.sipsolutions.net>
References: <1365952723-23295-1-git-send-email-amwang@redhat.com>
	 <CACraW2oiz27V0fvN2+hxP55hntiMT9QSJTqecjLAGrUXG6i+wA@mail.gmail.com>
	 (sfid-20130415_124006_755244_5F92EBF7) <1366024170.8361.12.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hidaki <yoshfuji@linux-ipv6.org>
To: Tomas Melin <tomas.melin@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49253 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab3DOLMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 07:12:43 -0400
In-Reply-To: <1366024170.8361.12.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 13:09 +0200, Johannes Berg wrote:

> That works for me, but it seems pretty pointless to have this API?
> Anyway, let me know if you want to apply this patch, then I'll drop mine
> and also remove the ifdefs from mac80211.

Oh, I misunderstood the patch. This actually makes Tomas's configuration
possible and work, I guess.

Btw, if this is what you want to do then we can also fix a number of
drivers to not have special Kconfig symbols for IPv6 etc.

johannes
