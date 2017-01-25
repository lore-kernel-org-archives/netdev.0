From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Wed, 25 Jan 2017 18:53:46 +0100
Message-ID: <20170125175346.GE23545@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170123211623.GE20894@1wt.eu>
 <1485279889.16328.306.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170124183446.GE21921@1wt.eu>
 <1485283885.16328.319.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170124191127.GG21921@1wt.eu>
 <CAC15z3izWNh7th_yxA_a90vgLnU5XzVDm6vyojq3cMDgQZ71YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:2392 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751372AbdAYRxy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 12:53:54 -0500
Content-Disposition: inline
In-Reply-To: <CAC15z3izWNh7th_yxA_a90vgLnU5XzVDm6vyojq3cMDgQZ71YA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei,

On Wed, Jan 25, 2017 at 09:15:34AM -0800, Wei Wang wrote:
> Willy,
> 
> Looks like you sent a separate patch on top of this patch series to address
> double connect().

Yes, sorry, I wanted to reply to this thread after the git-send-email
and got caught immediately after :-)

So as suggested by Eric in order to make the review easier, it was done
on top of your series.

> Then I think this patch series should be good to go.
> I will get your patch tested with our TFO test cases.

I think so as well. Thanks for running the tests. On my side I could fix
the haproxy bug which triggered this, and could verify the the whole
series works fine both with and without the haproxy fix. So I think we're
good now.

Thanks,
Willy
