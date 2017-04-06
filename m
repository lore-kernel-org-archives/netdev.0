From: Brian Norris <briannorris@chromium.org>
Subject: Re: [PATCH] mwifiex: MAC randomization should not be persistent
Date: Thu, 6 Apr 2017 09:48:08 -0700
Message-ID: <20170406164807.GB25323@google.com>
References: <20170405222640.4494-1-briannorris@chromium.org>
 <87inmifak8.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>, linux-kernel@vger.kernel.org,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34407 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752194AbdDFQsR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 12:48:17 -0400
Received: by mail-pg0-f42.google.com with SMTP id 21so41610673pgg.1
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 09:48:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87inmifak8.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 07:02:15AM +0300, Kalle Valo wrote:
> Brian Norris <briannorris@chromium.org> writes:
> 
> > nl80211 provides the NL80211_SCAN_FLAG_RANDOM_ADDR for every scan
> > request that should be randomized; the absence of such a flag means we
> > should not randomize. However, mwifiex was stashing the latest
> > randomization request and *always* using it for future scans, even those
> > that didn't set the flag.
> >
> > Let's zero out the randomization info whenever we get a scan request
> > without NL80211_SCAN_FLAG_RANDOM_ADDR. I'd prefer to remove
> > priv->random_mac entirely (and plumb the randomization MAC properly
> > through the call sequence), but the spaghetti is a little difficult to
> > unravel here for me.
> >
> > Fixes: c2a8f0ff9c6c ("mwifiex: support random MAC address for scanning")
> 
> So the first release with this was v4.9.
> 
> > Signed-off-by: Brian Norris <briannorris@chromium.org>
> > ---
> > Should this be tagged for -stable?
> 
> IMHO yes.

Sounds fine to me. I suppose you'll do this when applying? Or I can
resend...

Brian
