From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Sat, 02 May 2015 10:07:48 -0700
Message-ID: <55450464.8060109@plumgrid.com>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>	<20150502104621.4fede885@redhat.com>	<5544F4D7.50202@plumgrid.com> <20150502184625.25426091@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38089 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbbEBRHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 13:07:51 -0400
Received: by igbhj9 with SMTP id hj9so58293103igb.1
        for <netdev@vger.kernel.org>; Sat, 02 May 2015 10:07:51 -0700 (PDT)
In-Reply-To: <20150502184625.25426091@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/15 9:46 AM, Jesper Dangaard Brouer wrote:
> Okay, I guess it makes sense as a "mode".
>
> Calling it "stack_inject" is fairly descriptive, but I also like
> Daniel's idea of option "xmit_mode [rx|tx]".

sure. that's fine too.

> I would not allow it to be reconfigured on the fly, but only when the
> test/thread is stopped (!pkt_dev->running), allow re-configuring back
> to "TX" mode.  Although, removing (and free) the entire pkt_dev, would
> implicitly reset it back.

all makes sense.
btw, I'm off the grid till Monday and it sounds like you see concrete
spots in the code to hack this stuff in, so if you want to take over,
please go ahead :)
