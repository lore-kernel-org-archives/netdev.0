From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Recurring trace from tcp_fragment()
Date: Fri, 29 May 2015 15:46:43 -0400
Message-ID: <CADVnQyngTDVYMhmQq=pjS3LrdQ+HXyizujiOkmgXxTjQ0QKH8A@mail.gmail.com>
References: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35113 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539AbbE2Tqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 15:46:43 -0400
Received: by obcnx10 with SMTP id nx10so59877736obc.2
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 12:46:43 -0700 (PDT)
In-Reply-To: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 3:21 PM, Grant Zhang <gzhang@fastly.com> wrote:
> We have multiple machines running into the following trace repeatedly. The trace shows up every couple of seconds on our production machines.
>
...
> May 29 18:14:04 cache-fra1230 kernel:[3080455.796188]  [<ffffffff81678174>] tcp_fragment+0x2e4/0x2f0
> May 29 18:14:04 cache-fra1230 kernel:[3080455.796191]  [<ffffffff8166edeb>] tcp_mark_head_lost+0xeb/0x290
> May 29 18:14:04 cache-fra1230 kernel:[3080455.796193]  [<ffffffff8166fe28>] tcp_update_scoreboard+0x58/0x90
> May 29 18:14:04 cache-fra1230 kernel:[3080455.796195]  [<ffffffff8167422d>] tcp_fastretrans_alert+0x75d/0xb30
> May 29 18:14:04 cache-fra1230 kernel:[3080455.796197]  [<ffffffff816750d5>] tcp_ack+0xa15/0xf50

I'm glad you are seeing this so often. :-) We see this warning too,
but only very occasionally.

Our team has a proposed fix, but we have so far been unable to test it
thoroughly since it happens so rarely in our environment. Would you be
willing to test a small patch aimed at fixing this warning?

neal
