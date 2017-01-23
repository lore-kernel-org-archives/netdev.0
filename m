From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 00:01:57 +0100
Message-ID: <20170123230157.GJ20894@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170123211623.GE20894@1wt.eu>
 <CAEA6p_DxVMAry1PCz_idmk=TGpnnTib3WpWso03FB1oMVXN+sg@mail.gmail.com>
 <20170123213732.GF20894@1wt.eu>
 <20170123220121.GG20894@1wt.eu>
 <20170123223319.GH20894@1wt.eu>
 <CAC15z3g8OxZNET+OnvcyYwHYuHq7QBamgGmjkBHzDr-XnUSGDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:63126 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751183AbdAWXCE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 18:02:04 -0500
Content-Disposition: inline
In-Reply-To: <CAC15z3g8OxZNET+OnvcyYwHYuHq7QBamgGmjkBHzDr-XnUSGDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 02:57:31PM -0800, Wei Wang wrote:
> Yes. That seems to be a valid fix to it.
> Let me try it with my existing test cases as well to see if it works for
> all scenarios I have.

Perfect. Note that since the state 2 is transient I initially thought
about abusing the flags passed to __inet_stream_connect() to say "hey
I'm sendmsg() and not connect()" but that would have been a ugly hack
while here we really have the 3 socket states represented eventhough
one changes twice around a call.

Thanks,
Willy
