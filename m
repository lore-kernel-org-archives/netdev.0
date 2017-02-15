From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net] packet: Do not call fanout_release from atomic
 contexts
Date: Wed, 15 Feb 2017 13:34:32 -0800
Message-ID: <1487194472.1311.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487190339-6366-1-git-send-email-anoob.soman@citrix.com>
         <1487192551.1311.28.camel@edumazet-glaptop3.roam.corp.google.com>
         <83b09a68-b759-2ae5-5918-53581731c9bf@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33830 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752371AbdBOVee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 16:34:34 -0500
Received: by mail-pg0-f47.google.com with SMTP id z67so8008353pgb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:34:34 -0800 (PST)
In-Reply-To: <83b09a68-b759-2ae5-5918-53581731c9bf@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 21:30 +0000, Anoob Soman wrote:

> If statement looks like this.
> if (atomic_dec_and_test(sk_ref))
>      list_del(f->list);
> else
>     f = NULL;
> 
> there are no multiple lines under if.


Yes, I just noticed that.

Thanks.
