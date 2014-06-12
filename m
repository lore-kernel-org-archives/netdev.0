From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net] rtnetlink: fix userspace API breakage for iproute2 < v3.9.0
Date: Thu, 12 Jun 2014 11:01:30 -0700
Message-ID: <CA+55aFyYO8CrhV=nunf45LytQ3Rziprziu=K7N4wUtuemNWGiA@mail.gmail.com>
References: <538DBDB3.7030505@redhat.com>
	<5399B575.7070604@redhat.com>
	<CA+55aFxQMw0s1N2SspU-DWbZ-h4mho4dVFrX5qm=ZHKrsUGbmw@mail.gmail.com>
	<20140612.104735.11248268473559858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Schmidt <mschmidt@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	michael.riesch@omicron.at
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f182.google.com ([209.85.128.182]:47809 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaFLSBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 14:01:31 -0400
Received: by mail-ve0-f182.google.com with SMTP id oy12so270677veb.41
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 11:01:30 -0700 (PDT)
In-Reply-To: <20140612.104735.11248268473559858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2014 at 10:47 AM, David Miller <davem@davemloft.net> wrote:
>
> Yeah I guess you're right and I'll end up applying Michal's patch.

Note, as usual, I love it when we can just silently fix our broken
kernel semantics, and change the ABI to be saner. I'm not saying we
shouldn't do that. Some people think that my "don't break user space"
means some kind of absolute "ABI can never be changed". That's not the
case.

It's just that when we get caught doing so, and people complain, we
have to just own up to our interfaces having been less than optimal
(aka "crap") and try to make everybody happy.

In this case, hopefully in a few years, nobody runs RHEL6 any more and
we can remove ugly compatibility crap. But as it is, RHEL 6 isn't
quite old enough to ignore. If it was something like RHEL4 or older, I
think we could say "yeah, we can't really find it in ourselves to
care".

            Linus
