From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Create ieee80211_if_process_skb from
 ieee80211_iface_work
Date: Fri, 05 May 2017 11:06:18 +0200
Message-ID: <1493975178.2500.0.camel@sipsolutions.net>
References: <401d68b9015dc036589c99a26ef4664000cc821e.1493919003.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <401d68b9015dc036589c99a26ef4664000cc821e.1493919003.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> o Use explicit casts to proper types instead of casts to (void *)
>   and have the compiler do the implicit cast

I see no advantage in this, why? All it does is make the code longer,
and if anything changes, you have to change it in multiple places now.

johannes
