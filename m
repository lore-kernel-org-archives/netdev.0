From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: hung task in mac80211
Date: Wed, 06 Sep 2017 16:30:00 +0200
Message-ID: <1504708200.23905.3.camel@sipsolutions.net>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
         <1504702728.13457.17.camel@sipsolutions.net>
         <20170906162748.071b040e@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <mcroce@redhat.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54018 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932260AbdIFOaD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:30:03 -0400
In-Reply-To: <20170906162748.071b040e@elisabeth>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-06 at 16:27 +0200, Stefano Brivio wrote:
> 
> Sorry for the extended bothering :) but here, you're extending quite
> a bit the scope of the lock also
> when__ieee80211_start_rx_ba_session() is called by
> ieee80211_process_addba_request().

I know, but it doesn't matter.

> No idea what the hit can be, but we can't safely assume it's

> nothing either.   

We don't really have to assume anything, we can read the code :-)

Trust me, I probably wrote most of it. It's fine, just sanity checks.

> What about simply introducing a 'ampdu_mlme_lock_held' argument
> instead?

Eww, no.

johannes
