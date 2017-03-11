From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 04/14] net: dsa: mv88e6xxx: rework ATU Load/Purge
Date: Sun, 12 Mar 2017 00:40:21 +0100
Message-ID: <20170311234021.GE15842@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-5-vivien.didelot@savoirfairelinux.com>
 <20170310022748.GI22101@lunn.ch>
 <87zigrzg6s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44855 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751325AbdCKXk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 11 Mar 2017 18:40:26 -0500
Content-Disposition: inline
In-Reply-To: <87zigrzg6s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I really wished you had moved the code, unmodified, into
> > global1_atu.c. Then made lots of easy to review small changes. I
> > cannot just look at this patch and know it is correct. What i need to
> > compare against is not in this patch. So it is a lot harder to review.
> 
> I've addressed all of your comments in this patchset except this one.

Hi Vivien

This time, i'm not going to push the issue further. But next time i
will.

The point is, we have working code. You don't just throw that
away. You make lots of small changes to that working code to morph it
into the code you want. These small changes are all very quick and
easy to review, because they are all small and obvious. At each stage
we have working code. If somehow it does break, it is easy to bisect
it down to one small change. The actual likelyhood of breaking it is
small, because the changes are all small and obviously correct.

It does result in more patches, more to review, but it is much easier
to review, because it should be obviously correct. The overall lines
of code at the end is the same. So overall there is no harm is having
lots of small patches.

> A patch file cannot guarantee that a chunk of code moved around has not
> been altered in the process. This will just generate more diff for no
> value, that needs to be updated afterwards anyway.

I don't need a guarantee. I would trust you have moved it, without
editing it. Generating more diff is not a problem. The number of diffs
is not important at all. What is important is lots of small, easy to
review, obviously correct patches.

> Plus you already complained in the first iteration I sent about
> modifying lines that I previously added. I took care of logically
> splitting the new ATU Load/Purge, GetNext, Flush and Remove operations
> into incremental unmodified chunks in this series.

Unfortunately, you are splitting in the wrong dimension. None of this
is obviously correct. But it easily code of been.

   Andrew
