From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next repost 1/3] idr: Use unsigned long instead of
 int
Date: Wed, 16 Aug 2017 07:57:18 -0700
Message-ID: <1502895438.4936.121.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502871244-19870-1-git-send-email-chrism@mellanox.com>
         <1502871244-19870-2-git-send-email-chrism@mellanox.com>
         <1502879829.4936.100.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170816105305.GH1868@nanopsycho>
         <1502881133.4936.104.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170816110612.GI1868@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net,
        mawilcox@microsoft.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38882 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdHPO5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 10:57:30 -0400
Received: by mail-pf0-f196.google.com with SMTP id h75so1576041pfh.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 07:57:30 -0700 (PDT)
In-Reply-To: <20170816110612.GI1868@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 13:06 +0200, Jiri Pirko wrote:
> Wed, Aug 16, 2017 at 12:58:53PM CEST, eric.dumazet@gmail.com wrote:
> >On Wed, 2017-08-16 at 12:53 +0200, Jiri Pirko wrote:
> >
> >> rhashtable is unnecesary big hammer for this. IDR is nice fit for
> >> this purpose.
> >
> >Obviously IDR does not fit, since you have to change its ABI.
> 
> I don't think it is a problem to adjust something to your needs.
> Moreover, if it's API is misdesigned from the beginning. We are just
> putting IDR back on track, cleaning it's API. I don't see anything wrong
> on that. Everyone would benefit.

Except that your patch is gigantic, and nobody really can review it.

You could define idr_alloc_ext() maybe.

Then provide a patch series grouped so that each maintainer can review
its part.

Or leave legacy code using the old idr_alloc() in place.
