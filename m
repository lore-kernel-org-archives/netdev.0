From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 0/3] make skb accessors return void pointers
Date: Fri, 16 Jun 2017 00:12:14 +0200
Message-ID: <20170615221217.16510-1-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53850 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751882AbdFOWMV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 18:12:21 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.89)
        (envelope-from <johannes@sipsolutions.net>)
        id 1dLd00-0005sp-3R
        for netdev@vger.kernel.org; Fri, 16 Jun 2017 00:12:20 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After some more fun with spatch, I've come up with these three patches.

I couldn't figure out why spatch didn't convert one skb_put() place,
and there was one inside a macro it didn't find. Otherwise, it's
pretty much just spatch and changing the functions/prototypes.

I've compiled x86 allyesconfig with this and the skb_put_data() and
more skb_put_zero() conversions, but I'm going to wait for the 0-day
kbuild bot to tell me it succeeded on my branch (pushed all of this
to mac80211-next on the skb-access-cleanups branch) before I submit
all five patches properly.

There's, obviously, no way I'd even have attempted this before having
coccinelle :-)

johannes
