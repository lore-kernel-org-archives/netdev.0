From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: MAC randomization should not be persistent
Date: Thu, 06 Apr 2017 07:02:15 +0300
Message-ID: <87inmifak8.fsf@kamboji.qca.qualcomm.com>
References: <20170405222640.4494-1-briannorris@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>, <linux-kernel@vger.kernel.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Brian Norris <briannorris@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405222640.4494-1-briannorris@chromium.org> (Brian Norris's
        message of "Wed, 5 Apr 2017 15:26:40 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Norris <briannorris@chromium.org> writes:

> nl80211 provides the NL80211_SCAN_FLAG_RANDOM_ADDR for every scan
> request that should be randomized; the absence of such a flag means we
> should not randomize. However, mwifiex was stashing the latest
> randomization request and *always* using it for future scans, even those
> that didn't set the flag.
>
> Let's zero out the randomization info whenever we get a scan request
> without NL80211_SCAN_FLAG_RANDOM_ADDR. I'd prefer to remove
> priv->random_mac entirely (and plumb the randomization MAC properly
> through the call sequence), but the spaghetti is a little difficult to
> unravel here for me.
>
> Fixes: c2a8f0ff9c6c ("mwifiex: support random MAC address for scanning")

So the first release with this was v4.9.

> Signed-off-by: Brian Norris <briannorris@chromium.org>
> ---
> Should this be tagged for -stable?

IMHO yes.

-- 
Kalle Valo
