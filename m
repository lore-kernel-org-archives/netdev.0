From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next repost 1/3] idr: Use unsigned long instead of int
Date: Wed, 16 Aug 2017 17:00:23 +0200
Message-ID: <20170816150023.GA1750@nanopsycho>
References: <1502871244-19870-1-git-send-email-chrism@mellanox.com>
 <1502871244-19870-2-git-send-email-chrism@mellanox.com>
 <1502879829.4936.100.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170816105305.GH1868@nanopsycho>
 <1502881133.4936.104.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170816110612.GI1868@nanopsycho>
 <1502895438.4936.121.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net,
        mawilcox@microsoft.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36673 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751461AbdHPPAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:00:33 -0400
Received: by mail-wr0-f196.google.com with SMTP id y67so3530897wrb.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:00:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1502895438.4936.121.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 16, 2017 at 04:57:18PM CEST, eric.dumazet@gmail.com wrote:
>On Wed, 2017-08-16 at 13:06 +0200, Jiri Pirko wrote:
>> Wed, Aug 16, 2017 at 12:58:53PM CEST, eric.dumazet@gmail.com wrote:
>> >On Wed, 2017-08-16 at 12:53 +0200, Jiri Pirko wrote:
>> >
>> >> rhashtable is unnecesary big hammer for this. IDR is nice fit for
>> >> this purpose.
>> >
>> >Obviously IDR does not fit, since you have to change its ABI.
>> 
>> I don't think it is a problem to adjust something to your needs.
>> Moreover, if it's API is misdesigned from the beginning. We are just
>> putting IDR back on track, cleaning it's API. I don't see anything wrong
>> on that. Everyone would benefit.
>
>Except that your patch is gigantic, and nobody really can review it.
>
>You could define idr_alloc_ext() maybe.
>
>Then provide a patch series grouped so that each maintainer can review
>its part.
>
>Or leave legacy code using the old idr_alloc() in place.

Fair. Thanks.
