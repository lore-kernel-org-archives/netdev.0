From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next repost 1/3] idr: Use unsigned long instead of int
Date: Wed, 16 Aug 2017 13:06:12 +0200
Message-ID: <20170816110612.GI1868@nanopsycho>
References: <1502871244-19870-1-git-send-email-chrism@mellanox.com>
 <1502871244-19870-2-git-send-email-chrism@mellanox.com>
 <1502879829.4936.100.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170816105305.GH1868@nanopsycho>
 <1502881133.4936.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net,
        mawilcox@microsoft.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:38643 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdHPLGP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 07:06:15 -0400
Received: by mail-wr0-f195.google.com with SMTP id g32so2408538wrd.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 04:06:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1502881133.4936.104.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 16, 2017 at 12:58:53PM CEST, eric.dumazet@gmail.com wrote:
>On Wed, 2017-08-16 at 12:53 +0200, Jiri Pirko wrote:
>
>> rhashtable is unnecesary big hammer for this. IDR is nice fit for
>> this purpose.
>
>Obviously IDR does not fit, since you have to change its ABI.

I don't think it is a problem to adjust something to your needs.
Moreover, if it's API is misdesigned from the beginning. We are just
putting IDR back on track, cleaning it's API. I don't see anything wrong
on that. Everyone would benefit.


>
>If rhashtable does not fit this, then I wonder why we spent so many days
>of work adding it in the kernel.

It fits, sure. But it is not needed (the big hammer I mentioned).
We don't need a custom key for lookup. Just a single pointer as a key
would do. And that is exactly why IDR is here for. Does not make sense
to use anything else when we have the thing to do the work right here.
