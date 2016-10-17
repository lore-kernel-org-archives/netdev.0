From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211_hwsim: suggest nl80211 instead of wext driver
 in documentation
Date: Mon, 17 Oct 2016 11:39:04 +0200
Message-ID: <1476697144.19992.16.camel@sipsolutions.net>
References: <20161016223933.9484-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org
To: Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
        linux-wireless@vger.kernel.org, Jouni Malinen <j@w1.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49508 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757095AbcJQJji (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 05:39:38 -0400
In-Reply-To: <20161016223933.9484-1-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-17 at 00:39 +0200, Linus Lüssing wrote:
> For mac80211_hwsim interfaces, suggest to use wpa_supplicant with the
> more modern, netlink based driver instead of wext.

Makes sense, applied.

> Actually, I wasn't even able to make a connection with the
> configuration
> files and information provided in
> Documentation/networking/mac80211_hwsim/{README,hostapd.conf/wpa_supp
> licant.conf}
> 
This less so, we even have a few test cases we run regularly, but I
don't know. Maybe there's something special in those configuration
files that we don't test for otherwise.

johannes
