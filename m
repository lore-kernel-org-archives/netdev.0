From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] nl80211: fix enumeration type
Date: Thu, 20 Apr 2017 09:22:06 +0200
Message-ID: <1492672926.3109.5.camel@sipsolutions.net>
References: <20170420065513.1930-1-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Agner <stefan@agner.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51914 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943023AbdDTHWP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 03:22:15 -0400
In-Reply-To: <20170420065513.1930-1-stefan@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 23:55 -0700, Stefan Agner wrote:
> Use type enum nl80211_rate_info for bitrate information. This fixes
> a warning when compiling with clang:
>   warning: implicit conversion from enumeration type 'enum
> nl80211_rate_info'
>   to different enumeration type 'enum nl80211_attrs'

I'm pretty sure I just applied exactly these two patches very recently.

What made *two* people suddenly see this?

johannes
