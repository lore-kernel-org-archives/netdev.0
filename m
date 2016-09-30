From: =?utf-8?Q?Toke_H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>
Subject: Re: [PATCH 3/3] mac80211: Set lower memory limit for non-VHT devices
Date: Fri, 30 Sep 2016 16:35:49 +0200
Message-ID: <87h98x5ube.fsf@toke.dk>
References: <20160923195911.4572-1-toke@toke.dk>
        <20160923195911.4572-4-toke@toke.dk>
        <1475235230.17481.43.camel@sipsolutions.net> <87twcx5zll.fsf@toke.dk>
        <1475239915.17481.63.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: make-wifi-fast@lists.bufferbloat.net,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tohojo.dk ([77.235.48.147]:43822 "EHLO mail2.tohojo.dk"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933050AbcI3Of4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 10:35:56 -0400
In-Reply-To: <1475239915.17481.63.camel@sipsolutions.net> (Johannes Berg's
        message of "Fri, 30 Sep 2016 14:51:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

>> > I kinda see the logic here - we really don't need to queue as much
>> > if we can't possibly transmit it out quickly - but it seems to me
>> > we should also throw in some kind of limit that's relative to the
>> > amount of memory you have on the system?
>> 
>> Yes, ideally. That goes for FQ-CoDel as well, BTW. LEDE currently
>> carries a patch for that which just changes the hard-coded default to
>> another hard-coded default. Not sure how to get a good value to use,
>> though; and deciding on how large a fraction of memory to use for
>> packets starts smelling an awful lot like setting policy in the
>> kernel, doesn't it?
>
> Yeah, I agree it does seem awkward.
>
> Perhaps we should instead pick a low limit and let users change it
> more easily (i.e. not debugfs)? I don't know a good answer to this
> either.

Hmm, I'll talk it over with some of the LEDE people who are more used to
dealing with these sorts of memory-constrained devices than I am. Will
send a patch if we come up with a good solution :)

-Toke
