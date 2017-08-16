From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next repost 1/3] idr: Use unsigned long instead of
 int
Date: Wed, 16 Aug 2017 03:58:53 -0700
Message-ID: <1502881133.4936.104.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502871244-19870-1-git-send-email-chrism@mellanox.com>
         <1502871244-19870-2-git-send-email-chrism@mellanox.com>
         <1502879829.4936.100.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170816105305.GH1868@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net,
        mawilcox@microsoft.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:37598 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdHPK64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 06:58:56 -0400
Received: by mail-it0-f65.google.com with SMTP id 77so2189580itj.4
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 03:58:56 -0700 (PDT)
In-Reply-To: <20170816105305.GH1868@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 12:53 +0200, Jiri Pirko wrote:

> rhashtable is unnecesary big hammer for this. IDR is nice fit for
> this purpose.

Obviously IDR does not fit, since you have to change its ABI.

If rhashtable does not fit this, then I wonder why we spent so many days
of work adding it in the kernel.
