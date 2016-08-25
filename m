From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 16:49:58 +0200
Message-ID: <20160825144958.GA5248@breakpoint.cc>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
 <1471524527-10029-2-git-send-email-fw@strlen.de>
 <1471537092.29842.62.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160825090602.GA30509@breakpoint.cc>
 <1472134541.14381.126.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:50306 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759120AbcHYOvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 10:51:12 -0400
Content-Disposition: inline
In-Reply-To: <1472134541.14381.126.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Here at Google we have been using usec resolution in TCP timestamps for
> a while for all our DC traffic, and we have to upstream this at some
> point.
> 
> It would be nice if the randomization was optional, because having usec
> timestamps with a common base (ie no per flow random base) helps a lot
> to understand the host delays at transmit time, and receive time.

Would it help to make it per-host instead of per-flow?

> I will review your patch more in depth today, thanks.

Great, thanks a lot!
