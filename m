From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Wed, 17 May 2017 15:30:35 +0200
Message-ID: <1495027835.2442.13.camel@sipsolutions.net>
References: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
         <20170517100844.GC2849@medion.lan> (sfid-20170517_120840_185521_D3BC3321)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Bastian Bittorf <bb@npl.de>, Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40838 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754696AbdEQNai (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 09:30:38 -0400
In-Reply-To: <20170517100844.GC2849@medion.lan> (sfid-20170517_120840_185521_D3BC3321)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-17 at 12:08 +0200, Bastian Bittorf wrote:
> * Ben Greear <greearb@candelatech.com> [17.05.2017 11:51]:
> > I have been keeping an 'iw events' program running with a perl
> > script gathering its
> > output and post-processing it.  This has been working for several
> > years on 4.7 and earlier
> > kernels, but when testing on 4.9 overnight, I notice that 'iw
> > events' is not showing any input.  'strace' shows
> > that it is waiting on recvmsg.  If I start a second 'iw events'
> > then it will get
> > wifi events as expected.
> 
> me too, also seen on 4.4 - i'am happy for debug ideas.

I've never seen this.

Does it happen when it's very long-running? Or when there are lots of
events?

Perhaps something in the socket buffer accounting is going wrong, so
that it's slowly decreasing to 0?

johannes
