From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] skbuff: introduce skb_put_zero()
Date: Fri, 26 May 2017 08:58:49 +0200
Message-ID: <1495781929.2572.0.camel@sipsolutions.net>
References: <20170524070747.18573-1-johannes@sipsolutions.net>
         <20170525.130117.551364108206528221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51122 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763463AbdEZG6x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 02:58:53 -0400
In-Reply-To: <20170525.130117.551364108206528221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-25 at 13:01 -0400, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Wed, 24 May 2017 09:07:47 +0200
> 
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > This pattern was introduced a number of times in mac80211 just now,
> > and since it's present in a number of other places it makes sense
> > to add a little helper for it.
> > 
> > The transformations of all code were done with the following
> spatch:
[...]
> > NB: the patch won't apply to net-next because a few of the mac80211
> >     users don't exist there yet
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> 
> No objections, feel free to push this in via your mac80211 tree.

Do you think I should include the conversions in other drivers, or
would you prefer to get those as a separate patch later?

johannes
