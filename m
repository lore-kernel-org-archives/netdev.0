From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/3] mac80211: Set lower memory limit for non-VHT devices
Date: Fri, 30 Sep 2016 14:51:55 +0200
Message-ID: <1475239915.17481.63.camel@sipsolutions.net>
References: <20160923195911.4572-1-toke@toke.dk>
         <20160923195911.4572-4-toke@toke.dk>
         <1475235230.17481.43.camel@sipsolutions.net> <87twcx5zll.fsf@toke.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: make-wifi-fast@lists.bufferbloat.net,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42753 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932707AbcI3Mv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 08:51:59 -0400
In-Reply-To: <87twcx5zll.fsf@toke.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > I kinda see the logic here - we really don't need to queue as much
> > if we can't possibly transmit it out quickly - but it seems to me
> > we should also throw in some kind of limit that's relative to the
> > amount of memory you have on the system?
> 
> Yes, ideally. That goes for FQ-CoDel as well, BTW. LEDE currently
> carries a patch for that which just changes the hard-coded default to
> another hard-coded default. Not sure how to get a good value to use,
> though; and deciding on how large a fraction of memory to use for
> packets starts smelling an awful lot like setting policy in the
> kernel, doesn't it?

Yeah, I agree it does seem awkward.

Perhaps we should instead pick a low limit and let users change it more
easily (i.e. not debugfs)? I don't know a good answer to this either.

johannes
